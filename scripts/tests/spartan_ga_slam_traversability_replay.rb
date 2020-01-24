#! /usr/bin/env ruby

require 'rock/bundle'
require 'vizkit'

include Orocos

Bundles.initialize
Bundles.transformer.load_conf(
    Bundles.find_file('config', 'transforms_scripts_ga_slam.rb'))

Orocos.run(
    ####### Tasks #######
    'camera_bb2::Task' => 'camera_bb2',
    'camera_bb3::Task' => 'camera_bb3',
    'stereo::Task' => ['stereo_bb2', 'stereo_bb3', 'stereo_pancam'],
    'viso2::StereoOdometer' => 'viso2',
    'pancam_transformer::Task' => 'pancam_transformer',
    'gps_transformer::Task' => 'gps_transformer',
    'orbiter_preprocessing::Task' => 'orbiter_preprocessing',
    'ga_slam::Task' => 'ga_slam',
    'traversability::Task' => 'traversability',
    'spartan::Task' => 'spartan_vo',
    'viso2_with_imu::Task' => 'viso2_with_imu',
    'viso2_evaluation::Task' => 'viso2_evaluation',
    ####### Debug #######
    # :output => '%m-%p.log',
    # :gdb => ['ga_slam'],
    # :valgrind => ['ga_slam'],
    :valgrind_options => ['--track-origins=yes']) \
do
    ####### Replay Logs #######
    bag = Orocos::Log::Replay.open(
#       Nominal start
#        '/media/kvasir/Dataset1/9June/Traverse/20170609-1413/bb2.log',
#        '/media/kvasir/Dataset1/9June/Traverse/20170609-1413/bb3.log',
#        '/media/kvasir/Dataset1/9June/Traverse/20170609-1413/pancam.log',
#        '/media/kvasir/Dataset1/9June/Traverse/20170609-1413/waypoint_navigation.log',
#        '/media/kvasir/Dataset1/9June/Traverse/20170609-1413/imu.log',
#       Nurburing
#        '/media/kvasir/Dataset1/10June/Traverse/20170610-1448/bb2.log',
#        '/media/kvasir/Dataset1/10June/Traverse/20170610-1448/bb3.log',
#        '/media/kvasir/Dataset1/10June/Traverse/20170610-1448/pancam.log',
#        '/media/kvasir/Dataset1/10June/Traverse/20170610-1448/waypoint_navigation.log',
#        '/media/kvasir/Dataset1/10June/Traverse/20170610-1448/imu.log',
#       Nurburing End //Not used due to lack of time
#        '/media/kvasir/Dataset1/10June/Traverse/20170610-1615/bb2.log',
#        '/media/kvasir/Dataset1/10June/Traverse/20170610-1615/bb3.log',
#        '/media/kvasir/Dataset1/10June/Traverse/20170610-1615/pancam.log',
#        '/media/kvasir/Dataset1/10June/Traverse/20170610-1615/waypoint_navigation.log',
#        '/media/kvasir/Dataset1/10June/Traverse/20170610-1615/imu.log',
#       Side Track
#        '/media/heimdal/Dataset1/9June/Traverse/20170609-1556/bb2.log',
#        '/media/heimdal/Dataset1/9June/Traverse/20170609-1556/bb3.log',
#        '/media/heimdal/Dataset1/9June/Traverse/20170609-1556/pancam.log',
#        '/media/heimdal/Dataset1/9June/Traverse/20170609-1556/waypoint_navigation.log',
#        '/media/heimdal/Dataset1/9June/Traverse/20170609-1556/imu.log',
#       Eight Track (Dusk)
#        '/media/heimdal/Dataset1/9June/Traverse/20170609-1909/bb2.log',
#        '/media/heimdal/Dataset1/9June/Traverse/20170609-1909/bb3.log',
#        '/media/heimdal/Dataset1/9June/Traverse/20170609-1909/pancam.log',
#        '/media/heimdal/Dataset1/9June/Traverse/20170609-1909/waypoint_navigation.log',
#        '/media/heimdal/Dataset1/9June/Traverse/20170609-1909/imu.log',
#       Side Track (Galar)
#        '/media/galar/Dataset1/9June/Traverse/20170609-1556/bb2.log',
#        '/media/galar/Dataset1/9June/Traverse/20170609-1556/bb3.log',
#        '/media/galar/Dataset1/9June/Traverse/20170609-1556/pancam.log',
#        '/media/galar/Dataset1/9June/Traverse/20170609-1556/waypoint_navigation.log',
#        '/media/galar/Dataset1/9June/Traverse/20170609-1556/imu.log',
#       Nominal start (Galar)
        '/media/galar/Dataset1/9June/Traverse/20170609-1413/bb2.log',
        '/media/galar/Dataset1/9June/Traverse/20170609-1413/bb3.log',
        '/media/galar/Dataset1/9June/Traverse/20170609-1413/pancam.log',
        '/media/galar/Dataset1/9June/Traverse/20170609-1413/waypoint_navigation.log',
        '/media/galar/Dataset1/9June/Traverse/20170609-1413/imu.log',
#       Eight Track (Dusk on galar)
#        '/media/galar/Dataset1/9June/Traverse/20170609-1909/bb2.log',
#        '/media/galar/Dataset1/9June/Traverse/20170609-1909/bb3.log',
#        '/media/galar/Dataset1/9June/Traverse/20170609-1909/pancam.log',
#        '/media/galar/Dataset1/9June/Traverse/20170609-1909/waypoint_navigation.log',
#        '/media/galar/Dataset1/9June/Traverse/20170609-1909/imu.log',

    )
    bag.use_sample_time = true

    ####### Configure Tasks #######
    camera_bb2 = TaskContext.get 'camera_bb2'
    Orocos.conf.apply(camera_bb2, ['loc_cam_front'], :override => true)
    camera_bb2.configure

    camera_bb3 = TaskContext.get 'camera_bb3'
    Orocos.conf.apply(camera_bb3, ['default'], :override => true)
    camera_bb3.configure

    stereo_bb2 = TaskContext.get 'stereo_bb2'
    Orocos.conf.apply(stereo_bb2, ['hdpr_bb2_ga_slam_tenerife'], :override => true)
    stereo_bb2.configure

    stereo_bb3 = TaskContext.get 'stereo_bb3'
    Orocos.conf.apply(stereo_bb3, ['hdpr_bb3_left_right'], :override => true)
    stereo_bb3.configure

    stereo_pancam = TaskContext.get 'stereo_pancam'
    Orocos.conf.apply(stereo_pancam, ['panCam'], :override => true)
    stereo_pancam.configure

    viso2 = TaskContext.get 'viso2'
    Orocos.conf.apply(viso2, ['bumblebee'], :override => true)
    Bundles.transformer.setup(viso2)
    viso2.configure

    spartan_vo = Orocos.name_service.get 'spartan_vo'
    spartan_vo.apply_conf_file("/home/galar/rock/perception/orogen/spartan/config/spartan::Task.yml", ["default"])
    Bundles.transformer.setup(spartan_vo);
    spartan_vo.configure

    viso2_with_imu = TaskContext.get 'viso2_with_imu'
    Orocos.conf.apply(viso2_with_imu, ['default'], :override => true)
    viso2_with_imu.configure

    viso2_evaluation = Orocos.name_service.get 'viso2_evaluation'
    Orocos.conf.apply(viso2_evaluation, ['default'], :override => true)
    viso2_evaluation.configure

    pancam_transformer = TaskContext.get 'pancam_transformer'
    Orocos.conf.apply(pancam_transformer, ['default'], :override => true)
    pancam_transformer.configure

    gps_transformer = TaskContext.get 'gps_transformer'
    gps_transformer.configure

    orbiter_preprocessing = TaskContext.get 'orbiter_preprocessing'
    #Orocos.conf.apply(orbiter_preprocessing, ['default'], :override => true)
    Orocos.conf.apply(orbiter_preprocessing, ['galar_default'], :override => true)
    # Orocos.conf.apply(orbiter_preprocessing, ['prepared'], :override => true)
    orbiter_preprocessing.configure

    ga_slam = TaskContext.get 'ga_slam'
    # Orocos.conf.apply(ga_slam, ['default'], :override => true)
    Orocos.conf.apply(ga_slam, ['default','test'], :override => true)
    Bundles.transformer.setup(ga_slam)
    ga_slam.configure

    traversability = Orocos.name_service.get 'traversability'
    Orocos.conf.apply(traversability, ['hdpr'], :override => true)
    traversability.configure

    # Copy parameters from ga_slam to orbiter_preprocessing
    orbiter_preprocessing.cropSize = ga_slam.orbiterMapLength
    orbiter_preprocessing.voxelSize = ga_slam.orbiterMapResolution

    ####### Connect Task Ports #######
    bag.camera_firewire_bb2.frame.connect_to        camera_bb2.frame_in
    bag.camera_firewire_bb3.frame.connect_to        camera_bb3.frame_in

    camera_bb2.left_frame.connect_to                stereo_bb2.left_frame
    camera_bb2.right_frame.connect_to               stereo_bb2.right_frame
    camera_bb3.left_frame.connect_to                stereo_bb3.left_frame
    camera_bb3.right_frame.connect_to               stereo_bb3.right_frame
    bag.pancam_panorama.left_frame_out.connect_to   stereo_pancam.left_frame
    bag.pancam_panorama.right_frame_out.connect_to  stereo_pancam.right_frame

    stereo_bb2.point_cloud.connect_to               ga_slam.hazcamCloud
    stereo_bb3.point_cloud.connect_to               ga_slam.loccamCloud
    stereo_pancam.point_cloud.connect_to            ga_slam.pancamCloud

    camera_bb2.left_frame.connect_to                spartan_vo.img_in_left
    camera_bb2.right_frame.connect_to               spartan_vo.img_in_right

    bag.pancam_panorama.
        tilt_angle_out_degrees.connect_to           pancam_transformer.pitch
    bag.pancam_panorama.
        pan_angle_out_degrees.connect_to            pancam_transformer.yaw
    pancam_transformer.transformation.connect_to    ga_slam.pancamTransformation

    bag.gps_heading.pose_samples_out.connect_to     gps_transformer.inputPose
    bag.gps_heading.pose_samples_out.connect_to     orbiter_preprocessing.
                                                        robotPose
    # Spartan VO tasks
    spartan_vo.delta_vo_out.connect_to                  viso2_with_imu.delta_pose_samples_in

    bag.imu_stim300.orientation_samples_out.connect_to  viso2_with_imu.pose_samples_imu
    #gps_transformer.outputPose.connect_to               viso2_with_imu.pose_samples_imu
    #bag.gps.pose_samples.connect_to                     viso2_with_imu.pose_samples_imu

    viso2_with_imu.pose_samples_out.connect_to          viso2_evaluation.odometry_pose
    #spartan_vo.vo_out.connect_to                        viso2_evaluation.odometry_pose

    gps_transformer.outputPose.connect_to               viso2_evaluation.groundtruth_pose
    #bag.gps.pose_samples.connect_to                     viso2_evaluation.groundtruth_pose
    #bag.gps_heading.pose_samples.connect_to                     viso2_evaluation.groundtruth_pose

    gps_transformer.outputPose.connect_to               viso2_evaluation.groundtruth_pose_not_aligned
    #bag.gps.pose_samples.connect_to                     viso2_evaluation.groundtruth_pose_not_aligned

    viso2_evaluation.odometry_in_world_pose.connect_to  ga_slam.odometryPose
    #gps_transformer.outputDriftPose.connect_to      ga_slam.odometryPose

    # Connect IMU (roll, pitch) + Laser Gyro (yaw)
    gps_transformer.outputPose.connect_to           ga_slam.imuOrientation

    orbiter_preprocessing.pointCloud.connect_to     ga_slam.orbiterCloud
    gps_transformer.outputPose.connect_to           ga_slam.orbiterCloudPose

    ga_slam.elevationMap.connect_to                 traversability.elevation_map

    ####### Start Tasks #######
    camera_bb2.start
    camera_bb3.start
    # stereo_bb2.start
    stereo_bb3.start
    # stereo_pancam.start
    # viso2.start
    spartan_vo.start
    viso2_with_imu.start
    viso2_evaluation.start
    # pancam_transformer.start
    gps_transformer.start
    orbiter_preprocessing.start
    ga_slam.start
    traversability.start

    #Orocos.log_all_ports

    viso2_evaluation.log_all_ports
    viso2_with_imu.log_all_ports
    spartan_vo.log_all_ports
    ga_slam.log_all_ports
    gps_transformer.log_all_ports

    ####### Vizkit Display #######
    # Vizkit.display viso2.pose_samples_out,
    #     :widget => Vizkit.default_loader.RigidBodyStateVisualization
    # Vizkit.display viso2.pose_samples_out,
    #     :widget => Vizkit.default_loader.TrajectoryVisualization
    # Vizkit.display gps_transformer.outputPose,
    #     :widget => Vizkit.default_loader.RigidBodyStateVisualization
    # Vizkit.display gps_transformer.outputPose,
    #     :widget => Vizkit.default_loader.TrajectoryVisualization
    # Vizkit.display ga_slam.estimatedPose,
    #     :widget => Vizkit.default_loader.RigidBodyStateVisualization
    # Vizkit.display ga_slam.estimatedPose,
    #     :widget => Vizkit.default_loader.TrajectoryVisualization

    # Vizkit.display camera_bb2.left_frame
    Vizkit.display camera_bb3.left_frame
    # Vizkit.display bag.pancam_panorama.left_frame_out

    # Vizkit.display stereo_bb2.point_cloud
    # Vizkit.display stereo_bb3.point_cloud
    # Vizkit.display stereo_pancam.point_cloud
    # Vizkit.display viso2.point_cloud_samples_out
    # Vizkit.display ga_slam.mapCloud

    # Vizkit.display ga_slam.elevationMap

    # Vizkit.display orbiter_preprocessing.pointCloud

    ####### Vizkit Replay Control #######
    control = Vizkit.control bag
    control.speed = 1.0
#    control.seek_to 13000 # Nominal
    control.seek_to 50000 # Nominal right before moving
#    control.seek_to 48545 # Nominal ~10 sec before moving
#    control.seek_to 34700 #17181 #34000 #31000 # Nurburing
#    control.seek_to 59000 # Eight Track Dusk
#    control.seek_to 15378 #4955 #24000 #15378 # Side Track
    control.bplay_clicked

    ####### ROS RViz #######
    #spawn 'roslaunch ga_slam_visualization ga_slam_visualization.launch'

    sleep 3

    ####### Vizkit #######
    Vizkit.exec
end

