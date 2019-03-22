#!/bin/bash

docker run -it \
       --rm \
       --volume="$(pwd)/ros_files:/home/ros" \
       --user=ros \
       libpointmatcher
