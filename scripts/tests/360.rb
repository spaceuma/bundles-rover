#!/usr/bin/env ruby

require 'orocos'
require 'rock/bundle'
require 'readline'
include Orocos

# Initialize bundles to find the configurations for the packages
Bundles.initialize

# Execute the task
Orocos::Process.run 'unit_360', 'unit_shutter_controller' do
    ptu_directedperception = Orocos.name_service.get 'ptu_directedperception'
    Orocos.conf.apply(ptu_directedperception, ['default'], :override => true)
    ptu_directedperception.configure
    
    pancam_left = Orocos.name_service.get 'pancam_left'
    Orocos.conf.apply(pancam_left, ['grashopper2_left'], :override => true)
    pancam_left.configure
    
    pancam_right = Orocos.name_service.get 'pancam_right'
    Orocos.conf.apply(pancam_right, ['grashopper2_right'], :override => true)
    pancam_right.configure
    
    pancam_360 = Orocos.name_service.get 'pancam_360'
#    Orocos.conf.apply(pancam_360, ['default', 'apriltag'], :override => true)
    Orocos.conf.apply(pancam_360, ['default', 'separation_40'], :override => true)
    pancam_360.configure

    shutter_controller = Orocos.name_service.get 'shutter_controller'
    Orocos.conf.apply(shutter_controller, ['default'], :override => true)
    shutter_controller.configure
    
    # For feedback connect the PTU angles to the pancam_360
    pancam_360.pan_angle_in.connect_to ptu_directedperception.pan_angle
    pancam_360.tilt_angle_in.connect_to ptu_directedperception.tilt_angle
    # Connect the motion translator to the PTU control
    pancam_360.pan_angle_out.connect_to ptu_directedperception.pan_set
    pancam_360.tilt_angle_out.connect_to ptu_directedperception.tilt_set

    pancam_left.frame.connect_to shutter_controller.frame
    pancam_left.shutter_value.connect_to shutter_controller.shutter_value
    pancam_right.shutter_value.connect_to shutter_controller.shutter_value
    
    pancam_left.frame.connect_to pancam_360.left_frame_in
    pancam_right.frame.connect_to pancam_360.right_frame_in
    
    #pancam_360.log_all_ports
    
    logger_360 = Orocos.name_service.get 'unit_360_Logger'
    logger_360.file = "pancam_360.log"
    logger_360.log(pancam_360.left_frame_out)
    logger_360.log(pancam_360.right_frame_out)
    logger_360.log(pancam_360.pan_angle_out_degrees)
    logger_360.log(pancam_360.tilt_angle_out_degrees)
    logger_360.log(pancam_360.set_id)
    #logger_360.start
    
    # Start the components
    pancam_left.start
    pancam_right.start

    shutter_controller.start
    puts "Waiting for shutter controller to settle"
    sleep 30
    shutter_controller.stop

    pancam_360.start
    ptu_directedperception.start
    
    $pass = 0
    while true
        if pancam_360.state == :RUNNING
            puts "Still taking a picture, waiting 5 seconds"
            sleep 5
        else
            puts "Finished all sets"
            break
        end
    end
end

