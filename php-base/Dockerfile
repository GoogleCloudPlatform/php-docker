# Copyright 2015 Google Inc.
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

# Dockerfile for PHP 5.6.

FROM gcr.io/google_appengine/debian8

# persistent / runtime deps
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
    curl \
    gettext \
    git \
    libbz2-1.0 \
    libicu52 \
    libmcrypt4 \
    libmemcached11 \
    libmemcachedutil2 \
    libpcre3 \
    libpng12-0 \
    libpq5 \
    libreadline6 \
    librecode0 \
    libsqlite3-0 \
    libxml2 \
    libxslt1.1 \
    zlib1g

ENV PHP_DIR=/opt/php \
    PHP56_DIR=/opt/php56 \
    PHP7_DIR=/opt/php7 \
    PHP56_VERSION=5.6.27 \
    PHP70_VERSION=7.0.12 \
    PATH=/opt/php/bin:$PATH

# gpgkeys for verifying the tarballs
COPY gpgkeys /gpgkeys

# BUILD PHP and other dependencies.
COPY build-scripts /build-scripts

RUN /bin/bash /build-scripts/apt_build_deps.sh install && \
    /bin/bash /build-scripts/build_php56.sh && \
    /bin/bash /build-scripts/build_php70.sh && \
    /bin/bash /build-scripts/apt_build_deps.sh uninstall

# Put config files into place.
COPY php.ini php-cli.ini $PHP56_DIR/lib/
COPY php.ini php-cli.ini $PHP7_DIR/lib/
COPY php-fpm.conf $PHP56_DIR/etc/php-fpm.conf
COPY php-fpm.conf $PHP7_DIR/etc/php-fpm.conf
RUN touch $PHP56_DIR/etc/php-fpm-user.conf $PHP7_DIR/etc/php-fpm-user.conf

CMD ["php", "-a"]
