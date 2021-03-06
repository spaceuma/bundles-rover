#!/usr/bin/env ruby

require 'orocos'
require 'rock/bundle'
require 'readline'
include Orocos

# Initialize bundles to find the configurations for the packages
Bundles.initialize

# Execute the task
Orocos::Process.run 'hdpr_unit_gps' do

    # Configure
    gps = TaskContext.get 'gps'
    # Change the country configuration depeding on where on Earth the rover is
    Orocos.conf.apply(gps, ['HDPR', 'Netherlands', 'calibration'], :override => true)
    gps.configure

    # Log
    #Orocos.log_all_ports

    # Start
    gps.start
    
    Readline::readline("Press Enter to exit\n") do
    end
end 
