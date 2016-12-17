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
#   docker run -v /mydir:/workspace php-builder 5.6.29-1,7.0.14-2
# Then you'll get deb packages in /mydir.

# Inherit the php base image so we use the same dependency libraries
FROM gcr.io/google_appengine/php

ENV PHP_BUILDER_DIR /opt/php-builder

# copy the gpgkeys again
COPY gpgkeys /gpgkeys

# Need to install debian packaging tools etc
RUN apt-get update -y && \
    apt-get install -y -q --no-install-recommends \
        debhelper \
        devscripts \
        libparse-debcontrol-perl \
	# headlers
        libbz2-dev \
        libcurl4-openssl-dev \
        libgettextpo-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
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
        binutils

# Copy debian metadata file templates
RUN mkdir -p ${PHP_BUILDER_DIR}
COPY debian ${PHP_BUILDER_DIR}/debian

COPY build.sh ${PHP_BUILDER_DIR}/build.sh

ENTRYPOINT ["/opt/php-builder/build.sh"]
