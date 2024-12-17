#!/bin/bash

# Stop all containers
docker-compose -f docker/docker-compose-peers.yaml down
docker-compose -f docker/docker-compose-orderer.yaml down
docker-compose -f docker/docker-compose-ca.yaml down
docker-compose -f docker/docker-compose-monitoring.yaml down

# Remove containers and generated artifacts
docker rm -f $(docker ps -aq)
docker volume prune -f

echo "Network stopped and cleaned up"