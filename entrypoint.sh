#!/bin/bash
set -e

WAIT_DAYS=${TARGET_HOUR:-7}
TARGET_HOUR=${TARGET_HOUR:-3}

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
      echo "* Changes detected"
      bash get-certs.sh
    fi
  fi
  sha1sum get-certs.sh > get-certs.sh.sha1
}

function start_haproxy {
  echo -e "\n * Starting HAProxy"
  haproxy -D -p /var/run/haproxy.pid -f haproxy.cfg
  echo -e "   ...done.\n"
}

function stop_haproxy {
  echo " * Stopping HAProxy"
	for pid in $(cat /var/run/haproxy.pid); do
    kill $pid
	done
	rm -f /var/run/haproxy.pid
  echo -e "   ...done.\n"
}

function renew_certs {
  certbot renew --standalone
}

function wait_interval {
  hour=$(date +"%H")
  if [ $hour -gt $TARGET_HOUR ]; then
      extra_hours=$((24-hour+TARGET_HOUR))
  else
      extra_hours=$((TARGET_HOUR-hour))
  fi
  echo -e "\n * Waiting $WAIT_DAYS days and $extra_hours hours"
  sleep $((WAIT_DAYS*86400+extra_hours*3600))
  echo -e "   ...done.\n"
}

mkdir -p /opt/haproxy/ssl
python3 gen_conf.py
request_certs
cat haproxy.cfg

while true; do
  bash load-certs.sh
  start_haproxy
  wait_interval
  stop_haproxy
  renew_certs
done
