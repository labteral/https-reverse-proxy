FROM brunneis/haproxy
RUN \
    yum -y install python3 \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && pip3 install pyyaml \
    && yum -y install epel-release yum-utils \
    && yum -y install certbot \
    && yum -y clean all
COPY gen_conf.py /opt/reverse-proxy/
COPY entrypoint.sh /usr/bin/
WORKDIR /opt/reverse-proxy/
ENTRYPOINT entrypoint.sh
