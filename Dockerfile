FROM ubuntu:24.04

# Set environment variable to disable user interaction
ENV DEBIAN_FRONTEND=noninteractive

ARG UID
ARG GID
ARG USERNAME

# Install packages
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    cmake-curses-gui \
    curl \
    git \
    htop \
    locales \
    ncurses-dev \
    mesa-utils \
    rsync \
    sudo \
    software-properties-common \
    tmux \
    unzip \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*


# Install OMPL (Open Motion Planning Library)
RUN mkdir -p /var/ompl \
    && cd /var/ompl \
    && wget https://ompl.kavrakilab.org/install-ompl-ubuntu.sh \
    && chmod u+x install-ompl-ubuntu.sh \
    && ./install-ompl-ubuntu.sh \
    && rm -rf /var/ompl

# Install ROS2 Jazzy
RUN locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 
    
RUN add-apt-repository universe \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null \
    && apt-get update && apt-get install -y \ 
    ros-dev-tools \
    ros-jazzy-desktop

# Create a non-root user with sudo privileges
# RUN adduser --disabled-password --gecos "" farmlab \
#     && usermod -aG sudo farmlab \
#     && echo 'farmlab ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers 

# Remove any user or group that conflicts with the desired UID/GID
RUN if getent passwd $UID; then \
      userdel -f $(getent passwd $UID | cut -d: -f1); \
    fi \
    && if getent group $GID; then \
      groupdel $(getent group $GID | cut -d: -f1); \
    fi
    
# Create the user and group with the specified UID and GID    
RUN addgroup --gid ${GID} ${USERNAME} \ 
    && adduser --uid ${UID} --gid ${GID} --disabled-password --gecos "" ${USERNAME} \
    && usermod -aG sudo ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers 

# Switch to the non-root user
USER ${USERNAME}

# Initialize rosdep
RUN sudo rosdep init \
    && rosdep update

# Modify .bashrc
RUN echo "alias l='ls -1'" >> ~/.bashrc \
    && echo "alias ll='ls -lah'" >> ~/.bashrc \
    && echo "alias 'cd..'='cd ..'" >> ~/.bashrc \
    && echo "alias tmux='tmux -2'" >> ~/.bashrc \
    # make bash autocomplete write every suggestion in a separate line
    && echo "bind 'set completion-display-width 0'" >> ~/.bashrc \
    && echo "export LANG=en_US.UTF-8" >> ~/.bashrc \
    && echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
    
# Ensure .bashrc is sourced when a new shell session starts
# RUN sudo echo 'source ~/.bashrc' >> ~/.bash_profile

WORKDIR /home/${USERNAME}

CMD ["sleep", "infinity"]
