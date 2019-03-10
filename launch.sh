#!/bin/bash
docker run -ti --net=host \
-v "$(pwd)"/domains.yaml:/opt/reverse-proxy/domains.yaml:ro \
-v "$(pwd)"/haproxy.yaml:/opt/reverse-proxy/haproxy.yaml:ro \
brunneis/reverse-proxy
