# Copyright 2016 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Dockerfile used to build php binaries.
# Example usage:
#   docker run -v /mydir:/workspace deb-package-builder 5.6.29-1,7.0.14-2
# Then you'll get deb packages in /mydir.

FROM gcr.io/gcp-runtimes/ubuntu_16_0_4

ENV PHP_DIR=/opt/php \
    PATH=/opt/php/bin:$PATH

# Need to install debian packaging tools etc
RUN apt-get update -y && \
    apt-get install -y -q --no-install-recommends \
        # Tools
        git \
        # PHP deps
        curl \
        libcurl3-gnutls \
        gettext \
        libbz2-1.0 \
        libgmp10 \
        libicu55 \
        libjpeg-turbo8 \
        liblua5.3-0 \
        libmcrypt4 \
        libmemcached11 \
        libmemcachedutil2 \
        libpcre3 \
        libpng12-0 \
        libpq5 \
        libreadline6 \
        librecode0 \
        libsasl2-modules \
        libsqlite3-0 \
        libxml2 \
        libxslt1.1 \
        sasl2-bin \
        zlib1g \
        # debian packages
        debhelper \
        devscripts \
        libparse-debcontrol-perl \
        # headers
        libbz2-dev \
        libcurl4-gnutls-dev \
        libfreetype6-dev \
        libgettextpo-dev \
        libgmp-dev \
        libuv1-dev \
        libicu-dev \
        libjpeg-turbo8-dev \
        libjson-c-dev \
        liblua5.3-dev \
        libmagick++-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libpcre3-dev \
        libpng-dev \
        libpq-dev \
        libreadline6-dev \
        libreadline-dev \
        librecode-dev \
        libsasl2-dev \
        libsqlite3-dev \
        libsodium-dev \
        libssl-dev \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev \
        libzip-dev \
        libzip4 \
        openssl \
        nginx \
        # build tools
        build-essential \
        autoconf \
        bison \
        file \
        flex \
        g++ \
        gcc \
        libc-dev \
        make \
        patch \
        pkg-config \
        re2c \
        binutils \
        # build tools for cassandra
        cmake \
        dh-exec \
        lsb-release \
        fakeroot \
        libtool \
        automake \
        autotools-dev \
        wget \
        software-properties-common \
        apt-transport-https

RUN wget -qO - https://packages.confluent.io/deb/5.0/archive.key | apt-key add - && \
        add-apt-repository "deb [arch=amd64] https://packages.confluent.io/deb/5.0 stable main" && \
        apt-get update && apt-get install -y librdkafka-dev librdkafka1

COPY build.sh /
RUN chmod 0755 /build.sh
RUN mkdir -p /workspace
WORKDIR /workspace

# COPY debian /workspace/debian
# COPY extensions /workspace/extensions
# COPY functions.sh /workspace/functions.sh
# COPY libraries /workspace/libraries
# COPY gpgkeys /workspace/gpgkeys

ENTRYPOINT ["/build.sh"]
