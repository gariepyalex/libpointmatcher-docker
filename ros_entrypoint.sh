#!/bin/bash
set -e

source /opt/ros/kinetic/setup.bash
HOME=/home/ros rosdep update

catkin_init_workspace /home/ros/catkin_ws/src || printf '\nWorkspace already initialized\n'

cd /home/ros/catkin_ws/
catkin_make
source /home/ros/catkin_ws/devel/setup.bash

exec "$@"

