#!/bin/bash

# Check if DISPLAY is set
if [ -z "$DISPLAY" ]; then
    echo "DISPLAY environment variable is not set. Please set DISPLAY to the X11 server you want to use."
    echo "Example: export DISPLAY=:10"
    exit 1
fi

# Allow connections to the X server from the container
xhost +local:docker

docker run -d -it \
    --user 1001:1001 \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /dev/dri/renderD128:/dev/dri/renderD128 \
	-v /home/$USER/Downloads/Farmlab:/Downloads/Farmlab \
    -v /home/$USER/workspace:/workspace \
    --ipc host \
    ros2-jazzy