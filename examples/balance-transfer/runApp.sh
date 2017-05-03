#!/bin/bash

function dkcl(){
        CONTAINER_IDS=$(docker ps -a | grep "dev-peer[0-9]-.*chaincode.*Exited" | awk '{print $1}')
	echo
        if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" = " " ]; then
                echo "========== No containers available for deletion =========="
        else
                docker rm $CONTAINER_IDS
        fi
	echo
}

function dkrm(){
        DOCKER_IMAGE_IDS=$(docker images | grep "dev-peer[0-9]-" | awk '{print $3}')
	echo
        if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" = " " ]; then
		echo "========== No images available for deletion ==========="
        else
                docker rmi $DOCKER_IMAGE_IDS
        fi
	echo
}

function restartNetwork() {
	echo

        #teardown the network and clean the containers and intermediate images
	cd artifacts
	docker-compose down
	dkcl
	dkrm

	#Cleanup the material
	rm -rf /tmp/hfc-test-kvs_peerOrg* $HOME/.hfc-key-store/ /tmp/fabric-client-kvs_peerOrg*

	#Start the network
	docker-compose up -d
	cd -
	echo
}

function installNodeModules() {
	echo
	if [ -d node_modules ]; then
		echo "============== node modules installed already ============="
	else
		echo "============== Installing node modules ============="
		npm install
	fi
	echo
}


restartNetwork

installNodeModules

PORT=4000 node app
