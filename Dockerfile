FROM ubuntu:xenial

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros-latest.list

# install packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    sudo \
    tmux \
    openssh-client \
    dirmngr \
    gnupg2

# install bootstrap tools
RUN apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools


# install gstreamer
RUN apt-get install -y gstreamer1.0-tools \
                       gstreamer1.0-libav \
                       libgstreamer1.0-dev \
                       libgstreamer-plugins-base1.0-dev \
                       libgstreamer-plugins-good1.0-dev && \
    rm -rf /var/lib/apt/lists/*

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# install gazebo
RUN curl -ssL http://get.gazebosim.org | sh

# install ros packages
ENV ROS_DISTRO kinetic
RUN apt-get update && apt-get install -y \
    ros-kinetic-ros-base \ 
    ros-kinetic-robot \ 
    ros-kinetic-perception \ 
    ros-kinetic-ackermann-msgs \
    ros-kinetic-ros-control \
    ros-kinetic-rqt-reconfigure \
    ros-kinetic-global-planner \
    ros-kinetic-teb-local-planner \
    ros-kinetic-teb-local-planner-tutorials \
    ros-kinetic-ros-controllers && \
    rm -rf /var/lib/apt/lists/*

RUN rosdep init

RUN apt-get update && apt-get install -y python-pip && \
    rm -rf /var/lib/apt/lists/*

#Install libpointmatcher
RUN cd /tmp/ && git clone https://github.com/ethz-asl/libnabo \
    && cd libnabo && mkdir build && cd build \
    && cmake .. && make -j7 && make install 

#Install libpointmatcher
RUN cd /tmp/ && git clone https://github.com/ethz-asl/libpointmatcher \
    && cd libpointmatcher && mkdir build && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/usr/local/ .. && make -j7 && make install 

#Install additional ros packages
RUN apt-get update && apt-get install -y ros-kinetic-gps-umd \
    ros-kinetic-nmea-msgs && \
    rm -rf /var/lib/apt/lists/*

ENV USERNAME ros
RUN useradd -m $USERNAME && \
        echo "$USERNAME:$USERNAME" | chpasswd && \
        usermod --shell /bin/bash $USERNAME && \
        usermod -aG sudo $USERNAME && \
        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
        chmod 0440 /etc/sudoers.d/$USERNAME && \
        # Replace 1000 with your user/group id
        usermod  --uid 1000 $USERNAME && \
        groupmod --gid 1000 $USERNAME

WORKDIR /home/ros/

# setup entrypoint
COPY ./ros_entrypoint.sh /


ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
