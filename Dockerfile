FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive
RUN \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
        python3 \
        python3-pip \
        haproxy \
        software-properties-common && \
    ln -s /usr/bin/python3.7 /usr/bin/python && \
    pip3 install pyyaml && \
    add-apt-repository universe && \
    echo -e '\n' | add-apt-repository ppa:certbot/certbot && \
    apt-get update && \
    apt-get install -y certbot && \
    apt-get clean
COPY gen_conf.py /opt/reverse-proxy/
COPY entrypoint.sh /usr/bin/
WORKDIR /opt/reverse-proxy/
ENTRYPOINT entrypoint.sh
