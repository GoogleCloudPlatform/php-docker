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
#   docker run -v /mydir:/workspace deb-package-builder 7.3.28-1,7.4.18-1,8.0.5-1
# Then you'll get deb packages in /mydir.

FROM gcr.io/gcp-runtimes/ubuntu_18_0_4

ENV PHP_DIR=/opt/php \
    PATH=/opt/php/bin:$PATH

# Need to install debian packaging tools etc
RUN apt-get update -y && \
    apt-get install -y -q --no-install-recommends \
        # Tools
        git \
        # PHP deps
        curl \
        libssl-dev \
        libssl1.1 \
        openssl \
        libcurl3-gnutls \
        gettext \
        libbz2-1.0 \
        libgmp10 \
        libicu60 \
        libjpeg-turbo8 \
        liblua5.3-0 \
        libmcrypt4 \
        libmemcached11 \
        libmemcachedutil2 \
        libpcre2-dev \
        libpcre2-8-0 \
        libpcre3 \
        libpng16-16 \
        libpq5 \
        libreadline7 \
        librecode0 \
        libsasl2-modules \
        libsqlite3-0 \
        libopenexr22 \
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
        fftw-dev \
        libfreetype6-dev \
        libgd-dev \
        libgettextpo-dev \
        libcfitsio-dev \
        libgif-dev \
        libgmp-dev \
        libicu-dev \
        libjpeg-turbo8-dev \
        libjson-c-dev \
        liblua5.3-dev \
        libmagick++-dev \
        libmatio-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libopenslide-dev \
        liborc-0.4-dev \
        libonig-dev \
        libpango1.0-dev \
        libpcre3-dev \
        libpng-dev \
        libpoppler-glib-dev \
        libpq-dev \
        libreadline6-dev \
        libreadline-dev \
        librecode-dev \
        libsasl2-dev \
        libsqlite3-dev \
        libsodium-dev \
        libwebp-dev \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev \
        libzip-dev \
        libzip4 \
        # out of date 1.0.2g ->
        nginx \
        # build tools
        build-essential \
        dpkg-dev \
        autoconf \
        bison \
        file \
        flex \
        g++-8 \
        gcc-8 \
        libc-dev \
        make \
        patch \
        pkg-config \
        re2c \
        binutils \
        valgrind \
        # ampq build tools
        ca-certificates \
        gnupg \
        # build tools for cassandra
        dh-exec \
        lsb-release \
        fakeroot \
        libtool \
        automake \
        autotools-dev \
        wget \
        software-properties-common \
        apt-transport-https

RUN wget https://downloads.datastax.com/cpp-driver/ubuntu/18.04/dependencies/libuv/v1.35.0/libuv1_1.35.0-1_amd64.deb && \
        dpkg -i libuv1_1.35.0-1_amd64.deb

RUN wget https://downloads.datastax.com/cpp-driver/ubuntu/18.04/dependencies/libuv/v1.35.0/libuv1-dev_1.35.0-1_amd64.deb && \
        dpkg -i libuv1-dev_1.35.0-1_amd64.deb

RUN wget -qO - https://packages.confluent.io/deb/5.0/archive.key | apt-key add - && \
        add-apt-repository "deb [arch=amd64] https://packages.confluent.io/deb/5.0 stable main" && \
        apt-get update && apt-get install -y librdkafka-dev librdkafka1

RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | \
        tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
        add-apt-repository "deb [arch=amd64] https://apt.kitware.com/ubuntu/ bionic main" && \
        apt-get update && apt-get install -y cmake

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
