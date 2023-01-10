# HTTPS Reverse Proxy
# Copyright (C) 2019-2021 Rodrigo Martínez <dev@brunneis.com>
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

FROM haproxy:lts-bullseye
LABEL maintainer="dev@brunneis.com"

################################################
# HTTPS REVERSE PROXY
################################################

USER root
RUN \
    apt-get update \
    && apt-get -y install python3 python3-pip \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && pip3 install pyyaml \
    && apt-get update && apt-get -y install certbot \
    && apt-get clean

COPY gen_conf.py /opt/https-reverse-proxy/
COPY entrypoint.sh /usr/bin/

WORKDIR /opt/https-reverse-proxy/

ENTRYPOINT entrypoint.sh
