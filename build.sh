#!/bin/bash
source env.sh
docker build -t $DOCKER_IMAGE .
