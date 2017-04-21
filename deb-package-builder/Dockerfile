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

# Inherit the php base image so we use the same dependency libraries
FROM gcr.io/google-appengine/php

# Need to install debian packaging tools etc
RUN echo "deb http://ftp.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list && \
    apt-get update -y && \
    apt-get install -y -q --no-install-recommends \
        debhelper \
        devscripts \
        libparse-debcontrol-perl \
        # headers
        libbz2-dev \
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libgettextpo-dev \
        libgmp-dev \
        libuv1-dev/jessie-backports \
        libicu-dev \
        libjpeg62-turbo-dev \
        libjson-c-dev \
        libmagick++-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libpcre3-dev \
        libpng-dev \
        libpq-dev \
        libreadline6-dev \
        librecode-dev \
        libsasl2-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev \
        # build tools
        build-essential \
        autoconf \
        bison \
        file \
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
        fakeroot

COPY build.sh /
RUN mkdir -p /workspace
WORKDIR /workspace

ENTRYPOINT ["/build.sh"]
