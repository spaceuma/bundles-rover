# Transformations for the ExoTer rover
# ############################################
## ESA - NPI
## Author: Javier Hidalgo Carrio
## Email: javier.hidalgo_carrio@dfki.de
## ###########################################
# The convention to follow is "frame1" => "frame2" means the base of frame2 is
# expressed in the base of frame1. Therefore Tbody_stim300 is expressing
# stim300_frame in body_frame. Keep in mind that if we have a vector in
# stim300_frame and we want to have it in body_frame.
# v_body = Tbody_stim300 v_stim300

############################
# Static transformations
############################
load_transformer_conf "#{ENV['AUTOPROJ_CURRENT_ROOT']}/bundles/rover/config/marta_transformations.rb"

############################
# Dynamic transformations
############################

# Transformation from Navigation to Body but transformer expected in the inverse sense
#dynamic_transform "localization_frontend.world_osg_to_world_out", "world" => "world_osg"
#static_transform Eigen::Quaternion.Identity(),
#    Eigen::Vector3.new( 2.0, 0.0, 0.0 ), "world" => "world_osg"

# Transformation from Navigation to Body but transformer expected in the inverse sense
#dynamic_transform "localization_frontend.world_to_navigation_out", "navigation" => "world"
#static_transform Eigen::Quaternion.Identity(),
#    Eigen::Vector3.new( 2.0, 0.0, 0.0 ), "navigation" => "world"

# Transformation from Navigation to Body but transformer expected in the inverse sense
#dynamic_transform "exoter_odometry.pose_samples_out", "body" => "navigation"

# Transformation from Lab frame (Vicon) to Body but transformer expected in the inverse sense
#dynamic_transform "pose_merge.pose", "body" => "lab"

# Transformation from mast to Pan and Tilt Unit but transformed expected in the inverse sense
dynamic_transform "ptu_control.mast_to_ptu_out", "ptu" => "mast"
#static_transform Eigen::Quaternion.Identity(),
#    Eigen::Vector3.new( 2.0, 0.0, 0.0 ), "ptu" => "mast"

# Transformation from rover body to navigation but transformed expected in the inverse sense
#dynamic_transform "gps_heading.pose_samples_out", "body" => "gnss_utm" # original gps one
dynamic_transform "vicon.pose_samples", "body" => "world_osg" # original gps one
#dynamic_transform "viso2_with_imu.pose_samples_out", "body" => "viso_world"

pp self
