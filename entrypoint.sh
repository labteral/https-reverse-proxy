#!/bin/bash
set -e

function request_certs {
  if [ ! -f get-certs.sh.sha1 ]; then
    sha1sum get-certs.sh > get-certs.sh.sha1
    bash get-certs.sh
  else
    exec 3>&2
    exec 2> /dev/null
    result=$(sha1sum -c get-certs.sh.sha1 | cut -d: -f 2 | xargs 2>/dev/null)
    exec 2>&3
    if [ "$result" != "OK" ]; then
      bash get-certs.sh
    fi
  fi
  sha1sum get-certs.sh > get-certs.sh.sha1
}

function start_haproxy {
  haproxy -db -p /var/run/haproxy.pid -f haproxy.cfg 
}

function stop_haproxy {
	for pid in $(cat /var/run/haproxy.pid); do
    kill $pid
	done
	rm -f /var/run/haproxy.pid
}

python3 gen_conf.py
request_certs
mkdir -p /opt/haproxy/ssl

while true; do
  certbot renew --standalone
  bash load-certs.sh
  start_haproxy
  sleep 86400 # 1 day
  stop_haproxy
done