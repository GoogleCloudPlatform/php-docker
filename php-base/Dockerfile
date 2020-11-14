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

# Dockerfile for PHP 7.1/7.2/7.3/7.4 using nginx as the webserver.

FROM gcr.io/gcp-runtimes/ubuntu_16_0_4

# Install build scripts - composer, nginx, php
COPY build-scripts /build-scripts
# Files for stackdriver setup
COPY stackdriver-files /stackdriver-files

RUN chown -R www-data /build-scripts /stackdriver-files

RUN apt-get update -y && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
    curl \
    gettext \
    git \
    libbz2-1.0 \
    libcurl3-gnutls \
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
    mercurial \
    nginx-extras \
    sasl2-bin \
    subversion \
    supervisor \
    wget \
    software-properties-common \
    apt-transport-https \
    zlib1g && \
    /bin/bash /build-scripts/apt-cleanup.sh

RUN wget -qO - https://packages.confluent.io/deb/5.0/archive.key | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://packages.confluent.io/deb/5.0 stable main" && \
    apt-get update && apt-get install -y librdkafka-dev librdkafka1

ENV NGINX_DIR=/etc/nginx \
    PHP_DIR=/opt/php \
    PHP_CONFIG_TEMPLATE=/opt/php-configs \
    PHP71_DIR=/opt/php71 \
    PHP72_DIR=/opt/php72 \
    PHP73_DIR=/opt/php73 \
    PHP74_DIR=/opt/php74 \
    APP_DIR=/app \
    NGINX_USER_CONF_DIR=/etc/nginx/conf.d \
    UPLOAD_DIR=/upload \
    SESSION_SAVE_PATH=/tmp/sessions \
    PATH=/opt/php/bin:$PATH \
    WWW_HOME=/var/www \
    COMPOSER_HOME=/opt/composer \
    DOCUMENT_ROOT=/app \
    FRONT_CONTROLLER_FILE=index.php

ARG RUNTIME_DISTRIBUTION="gcp-php-runtime-xenial-unstable"

COPY ${RUNTIME_DISTRUBTION} /${RUNTIME_DISTRUBTION}

RUN mkdir -p $PHP_CONFIG_TEMPLATE
COPY php-fpm.conf php.ini php-cli.ini "${PHP_CONFIG_TEMPLATE}/"

RUN apt-get -y update && \
	dpkg -i --force-depends /${RUNTIME_DISTRIBUTION}/*.deb && \
	apt-get install -yf --no-install-recommends && \
    (curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | apt-key add -) && \
	/bin/bash /build-scripts/dump_php_versions.sh && \
	/bin/bash /build-scripts/apt-cleanup.sh && \
	rm -rf /${RUNTIME_DISTRIBUTION}

EXPOSE 8080

# Lock down the web directories
RUN mkdir -p $APP_DIR $UPLOAD_DIR $SESSION_SAVE_PATH \
        $NGINX_USER_CONF_DIR $WWW_HOME $COMPOSER_HOME \
    && chown -R www-data.www-data \
        $APP_DIR $UPLOAD_DIR $SESSION_SAVE_PATH \
        $NGINX_USER_CONF_DIR $WWW_HOME $COMPOSER_HOME \
    && chmod 755 $UPLOAD_DIR $SESSION_SAVE_PATH $COMPOSER_HOME \
    && ln -sf ${PHP_DIR}/bin/php /usr/bin/php
# Linking for easy access to php with `su www-data -c $CMD`

# Put other config and shell files into place.
COPY nginx.conf fastcgi_params gzip_params "${NGINX_DIR}/"
COPY nginx-app.conf nginx-http.conf "${NGINX_USER_CONF_DIR}/"
COPY supervisord.conf /etc/supervisor/supervisord.conf

RUN chmod +x /build-scripts/entrypoint.sh /build-scripts/composer.sh

WORKDIR $APP_DIR

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
