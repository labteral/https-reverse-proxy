#!/bin/bash
source env.sh
docker run -ti --net=host \
-e LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL \
-v "$(pwd)"/letsencrypt:/etc/letsencrypt \
-v "$(pwd)"/domains.yaml:/opt/reverse-proxy/domains.yaml:ro \
-v "$(pwd)"/haproxy.yaml:/opt/reverse-proxy/haproxy.yaml:ro \
brunneis/reverse-proxy
