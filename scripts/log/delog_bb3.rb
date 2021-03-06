#! /usr/bin/env ruby

require 'orocos'
require 'orocos/log'
require 'rock/bundle'
require 'vizkit'


include Orocos

Bundles.initialize

# This ruby scripts takes the interclaced bb3 frame and saves three non interlaced triplets in a new logfile

Orocos.run 'camera_bb3::Task' => 'camera_bb3' do
    
    # declare logger of new ports
    logger_bb3_unrectified_pairs = Orocos.name_service.get 'camera_bb3_Logger'
    # new log destination
    logger_bb3_unrectified_pairs.file = "bb3_unrectifiedPairs.log"
    
    # new components to run on top of the log
    camera_bb3 = Orocos.name_service.get 'camera_bb3'
    Orocos.conf.apply(camera_bb3, ['default'], :override => true)
 
    # open log file to be postprocessed
    if ARGV.size == 0 then
		log_replay = Orocos::Log::Replay.open( "bb3.log") 
    else
		log_replay = Orocos::Log::Replay.open( ARGV[0]+"bb3.log") 
    end
    
    # uses timestamp when data was acquired
    log_replay.use_sample_time = true
    
    # new connection (either to logfed ports or new components
    log_replay.camera_firewire_bb3.frame.connect_to( camera_bb3.frame_in)
        
    # data to be logged
    logger_bb3_unrectified_pairs.log(camera_bb3.left_frame)
    logger_bb3_unrectified_pairs.log(camera_bb3.center_frame)
    logger_bb3_unrectified_pairs.log(camera_bb3.right_frame)

    # create intermediate data reader used for processing sync
    reader = camera_bb3.right_frame.reader
    
    # start the components
    camera_bb3.configure
    camera_bb3.start
    logger_bb3_unrectified_pairs.start    
    
    # start processing
    log_replay.step
    
    while !log_replay.eof? do
		if reader.read_new then 
			log_replay.step
			print log_replay.sample_index
			print ' over '
			puts log_replay.size
		else
			sleep 0.01
		end
    end

end

