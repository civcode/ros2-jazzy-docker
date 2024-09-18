#!/bin/bash

# Check if DISPLAY is set
if [ -z "$DISPLAY" ]; then
    echo "DISPLAY environment variable is not set. Please set DISPLAY to the X11 server you want to use."
    echo "Example: export DISPLAY=:10"
    exit 1
fi

# Check if HOST_USER is set
# if [ -z "$HOST_USER" ]; then
#     echo "HOST_USER environment variable is not set. Please set HOST_USER to the user you want to use in the container."
#     echo "Example: export HOST_USER=farmlab"
#     exit 1
# fi

# Allow connections to the X server from the container
xhost +local:docker

HOST_USER=${USER}

  #  --user $HOST_UID:$HOST_GID \
docker run -d -it \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /dev/dri/renderD128:/dev/dri/renderD128 \
	-v /home/$USER/Downloads/Farmlab:/home/${HOST_USER}/Downloads/Farmlab \
    -v /home/$USER/workspace:/home/${HOST_USER}/workspace \
    --ipc host \
    ros2-jazzy