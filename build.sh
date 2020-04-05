#!/bin/bash
source .env
docker build -t $DOCKER_IMAGE .
