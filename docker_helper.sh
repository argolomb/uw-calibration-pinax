#!/bin/bash

# initialize global variables
containerName=uw-calibration-pinax
containerTag=1.0
GREEN='\033[1;32m'
BLUE='\e[34m'
NC='\033[0m' # no color
user=`id -u -n`
userid=`id -u`
group=`id -g -n`
groupid=`id -g`
myhostname=pinax
no_proc=`nproc`

if [ "$#" -eq "0" ]; then
	echo -e "${GREEN}>>> Possible commands:\n ${NC}"
	echo -e "${BLUE}build --- Build an image based on DockerFile in current dir\n"
	echo -e "${BLUE}run --- Create and run container from image${NC}\n"
	echo -e "${BLUE}console --- Gives terminal access (/bin/bash) access to a running container${NC}\n"
    exit
fi

if [ "$1" = "build" ]; then
	echo -e "${GREEN}>>> Building Docker image ...${NC}"
	#/usr/bin/docker build --build-arg user=$user --build-arg userid=$userid --build-arg group=$group --build-arg groupid=$groupid -t ${user}/${repoName}:${imageTag} .
	docker build -t ${user}/${containerName}:${containerTag} .
fi

if [ "$1" = "run" ]; then

	echo -e "${GREEN}>>> Initializing "${containerName}" container...${NC}"
		if [ -d /sys/module/nvidia ]; then

		    NVIDIA_ARGS=""
		    for f in `ls /dev | grep nvidia`; do
		        NVIDIA_ARGS="$NVIDIA_ARGS --volume=/dev/${f}:/dev/${f}:rw"
		    done

		    NVIDIA_ARGS="$NVIDIA_ARGS --privileged"
		elif [ -d /dev/dri ]; then

		    DRI_ARGS=""
		    for f in `ls /dev/dri/*`; do
		        DRI_ARGS="$DRI_ARGS --device=$f"
		    done

		    DRI_ARGS="$DRI_ARGS --privileged"
		fi

	#docker run --rm --runtime=nvidia -it
	docker run --rm -it \
	    $DRI_ARGS \
	    --name="${containerName}" \
	    --hostname="${myhostname}" \
	    --net=default \
	    --workdir="/root" \
	    --volume=`pwd`/input_data:/root/input_data \
	    --volume=`pwd`/output_data:/root/output_data \
	    ${user}/${containerName}:${containerTag}
	    # error code 1 is harmless (meaning the container has been created already beforehand)
	    rc=$?; if [[ $rc != 0 && $rc != 1 ]]; then exit $rc; fi
		#--user="${userid}" \


fi

if [ $1 = "console" ]; then
	echo -e "${GREEN}>>> Entering console in container ${containerName} ...${NC}"
	docker exec -it ${containerName} /bin/bash
fi
