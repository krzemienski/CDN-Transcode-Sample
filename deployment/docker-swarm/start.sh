#!/bin/bash -e

DIR=$(dirname $(readlink -f "$0"))
export VIDEO_ARCHIVE_VOLUME=$(readlink -f "$DIR/../../volume/video/archive")
export VIDEO_DASH_VOLUME=$(readlink -f "$DIR/../../volume/video/dash")
export VIDEO_HLS_VOLUME=$(readlink -f "$DIR/../../volume/video/hls")
export HTML_VOLUME=$(readlink -f "$DIR/../../volume/html")

sudo docker container prune -f
sudo docker volume prune -f
sudo docker network prune -f
sudo rm -rf "${VIDEO_DASH_VOLUME}" "${VIDEO_HLS_VOLUME}"
sudo mkdir -p "${VIDEO_DASH_VOLUME}" "${VIDEO_HLS_VOLUME}"

yml="$DIR/docker-compose.$(hostname).yml"
test -f "$yml" || yml="$DIR/docker-compose.yml"

case "$1" in
docker_compose)
    dcv="$(docker-compose --version | cut -f3 -d' ' | cut -f1 -d',')"
    mdcv="$(printf '%s\n' $dcv 1.20 | sort -r -V | head -n 1)"
    if test "$mdcv" = "1.20"; then
        echo ""
        echo "docker-compose >=1.20 is required."
        echo "Please upgrade docker-compose at https://docs.docker.com/compose/install."
        echo ""
        exit 0
    fi
    . "$DIR/self-sign.sh"
    export USER_ID=$(id -u)
    export GROUP_ID=$(id -g)
    sudo -E docker-compose -f "$yml" -p ovc --compatibility up
    ;;
*)
    . "$DIR/self-sign.sh"
    export USER_ID=$(id -u)
    export GROUP_ID=$(id -g)
    sudo -E docker stack deploy -c "$yml" ovc
    ;;
esac
