#!/usr/bin/env ruby

require 'orocos'
require 'orocos/log'
require 'rock/bundle'
require 'vizkit'
require 'utilrb'

include Orocos

options = {}
options[:reference] = "none"
options[:imu] = "new"

op = OptionParser.new do |opt|
    opt.banner = <<-EOD
    usage: process_logs_exoter_visual_odometry [options] <data_log_directory>
    EOD

    opt.on "-r", "--reference=none/vicon/gnss", String, 'set the type of reference system available' do |reference|
        options[:reference] = reference
    end

    opt.on "-i", "--imu=old/new", String, 'since the imu component changed. Please set the type' do |imu|
        options[:imu] = imu
    end

    opt.on '--help', 'this help message' do
        puts opt
       exit 0
    end
end

args = op.parse(ARGV)
logfiles_path = args.shift

if !logfiles_path
    puts "missing path to log files"
    puts options
    exit 1
end

Orocos::CORBA::max_message_size = 100000000000
Bundles.initialize
Bundles.transformer.load_conf(Bundles.find_file('config', 'transforms_scripts.rb'))

# Configuration values
if options[:reference].casecmp("vicon").zero?
    puts "[INFO] Vicon Ground Truth system available"
elsif options[:reference].casecmp("gnss").zero?
    puts "[INFOR] GNSS Ground Truth system available"
else
    puts "[INFO] No Ground Truth system available"
end

Orocos::Process.run 'joint_dispatcher::Task' => 'read_joint_dispatcher',
                    'ptu_control::Task' => 'ptu_control',
                    'localization_frontend::Task' => 'localization_frontend',
                    'viso2::StereoOdometer' => 'visual_odometry' do

    ## Get the task context ##
    STDERR.print "setting up read_joint_dispatcher..."
    read_joint_dispatcher = Orocos.name_service.get 'read_joint_dispatcher'
    Orocos.conf.apply(read_joint_dispatcher, ['reading'], :override => true)
    STDERR.puts "done"

    ## Get the task context ##
    STDERR.print "setting up ptu_control..."
    ptu_control = Orocos.name_service.get 'ptu_control'
    Orocos.conf.apply(ptu_control, ['default'], :override => true)
    STDERR.puts "done"

    ## Get the task context ##
    STDERR.print "setting up localization_frontend..."
    localization_frontend = Orocos.name_service.get 'localization_frontend'
    Orocos.conf.apply(localization_frontend, ['default', 'hamming1hzsampling12hz'], :override => true)
    if options[:reference].casecmp("vicon").zero?
        localization_frontend.pose_reference_samples_period = 0.01 # Vicon is normally at 100Hz
    end
    if options[:reference].casecmp("gnss").zero?
        localization_frontend.pose_reference_samples_period = 0.1 # GNSS/GPS is normally at 10Hz
    end

    STDERR.puts "done"

    ## Get the task context ##
    STDERR.print "setting up visual_odometry..."
    visual_odometry = TaskContext.get 'visual_odometry'
    Orocos.conf.apply(visual_odometry, ['default', 'bumblebee'], :override => true)
    STDERR.puts "done"

    # logs files
    log_replay = Orocos::Log::Replay.open( logfiles_path )

    #################
    ## TRANSFORMER ##
    #################
    Bundles.transformer.setup(localization_frontend)
    Bundles.transformer.setup(visual_odometry)

    ###################
    ## LOG THE PORTS ##
    ###################
    Bundles.log_all

    ###############
    ## CONFIGURE ##
    ###############
    read_joint_dispatcher.configure
    ptu_control.configure
    localization_frontend.configure
    visual_odometry.configure

    ###########################
    ## LOG PORTS CONNECTIONS ##
    ###########################
    log_replay.platform_driver.joints_readings.connect_to(read_joint_dispatcher.joints_readings, :type => :buffer, :size => 200)

    if options[:imu].casecmp("old").zero?
        log_replay.stim300.orientation_samples_out.connect_to(localization_frontend.orientation_samples, :type => :buffer, :size => 200)
        log_replay.stim300.calibrated_sensors.connect_to(localization_frontend.inertial_samples, :type => :buffer, :size => 200)
    end

    if options[:imu].casecmp("new").zero?
        log_replay.imu_stim300.orientation_samples_out.connect_to(localization_frontend.orientation_samples, :type => :buffer, :size => 200)
        log_replay.imu_stim300.compensated_sensors_out.connect_to(localization_frontend.inertial_samples, :type => :buffer, :size => 200)
    end

    if options[:reference].casecmp("vicon").zero?
        log_replay.vicon.pose_samples.connect_to(localization_frontend.pose_reference_samples, :type => :buffer, :size => 200)
    end

    if options[:reference].casecmp("gnss").zero?
        log_replay.gnss_trimble.pose_samples.connect_to(localization_frontend.pose_reference_samples, :type => :buffer, :size => 200)
    end

    log_replay.camera_bb2.left_frame.connect_to(localization_frontend.left_frame, :type => :buffer, :size => 200)
    log_replay.camera_bb2.right_frame.connect_to(localization_frontend.right_frame, :type => :buffer, :size => 200)

    #############################
    ## TASKS PORTS CONNECTIONS ##
    #############################

    read_joint_dispatcher.joints_samples.connect_to localization_frontend.joints_samples
    read_joint_dispatcher.ptu_samples.connect_to ptu_control.ptu_samples

    localization_frontend.left_frame_out.connect_to visual_odometry.left_frame
    localization_frontend.right_frame_out.connect_to visual_odometry.right_frame

    ###########
    ## START ##
    ###########
    read_joint_dispatcher.start
    ptu_control.start
    localization_frontend.start
    visual_odometry.start

    # open the log replay widget
    control = Vizkit.control log_replay
    control.speed = 1

    Vizkit.exec


end
