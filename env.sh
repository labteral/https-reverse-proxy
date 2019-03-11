#!/bin/bash
LETSENCRYPT_EMAIL=webmaster@example.com
CERTS_DIR="$(pwd)/letsencrypt"
CONTAINER_NAME=reverse-proxy
DOCKER_IMAGE=brunneis/reverse-proxy
