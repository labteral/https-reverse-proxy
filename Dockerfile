# HTTPS Reverse Proxy
# Copyright (C) 2019-2020 Rodrigo Martínez <dev@brunneis.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

FROM brunneis/haproxy
LABEL maintainer="dev@brunneis.com"

################################################
# HTTPS REVERSE PROXY
################################################

RUN \
    yum -y install python3 \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && pip3 install pyyaml \
    && yum -y install epel-release yum-utils \
    && yum -y install certbot \
    && yum -y clean all

COPY gen_conf.py /opt/https-reverse-proxy/
COPY entrypoint.sh /usr/bin/

WORKDIR /opt/https-reverse-proxy/

ENTRYPOINT entrypoint.sh