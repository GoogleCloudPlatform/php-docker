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

# Dockerfile for PHP 5.6/7.0 using nginx as the webserver.

FROM gcr.io/google_appengine/debian8

RUN apt-get update -y && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
    curl \
    gettext \
    git \
    libbz2-1.0 \
    libicu52 \
    libjpeg62-turbo \
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
    sasl2-bin \
    subversion \
    supervisor \
    zlib1g

ENV NGINX_DIR=/etc/nginx \
    PHP_DIR=/opt/php \
    PHP_CONFIG_TEMPLATE=/opt/php-configs \
    PHP56_DIR=/opt/php56 \
    PHP70_DIR=/opt/php70 \
    PHP71_DIR=/opt/php71 \
    APP_DIR=/app \
    NGINX_USER_CONF_DIR=/etc/nginx/conf.d \
    UPLOAD_DIR=/upload \
    SESSION_SAVE_PATH=/tmp/sessions \
    PHP56_VERSION=5.6.30 \
    PHP70_VERSION=7.0.19 \
    PHP71_VERSION=7.1.5 \
    PATH=/opt/php/bin:$PATH \
    WWW_HOME=/var/www \
    COMPOSER_HOME=/opt/composer \
    DOCUMENT_ROOT=/app \
    FRONT_CONTROLLER_FILE=index.php

# Install build scripts - composer, nginx, php
COPY build-scripts /build-scripts

ARG RUNTIME_DISTRIBUTION="gcp-php-runtime-jessie"

RUN mkdir -p $PHP_CONFIG_TEMPLATE
COPY php-fpm.conf php.ini php-cli.ini "${PHP_CONFIG_TEMPLATE}/"

RUN (echo "deb http://packages.cloud.google.com/apt ${RUNTIME_DISTRIBUTION} main" \
    | tee /etc/apt/sources.list.d/gcp-php-runtime-jessie.list) && \
    (curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
      | apt-key add -) && \
    apt-get -y update && \
    /bin/bash /build-scripts/install_nginx.sh

EXPOSE 8080

# Lock down the web directories
RUN mkdir -p $APP_DIR $UPLOAD_DIR $SESSION_SAVE_PATH \
        $NGINX_USER_CONF_DIR $WWW_HOME $COMPOSER_HOME \
    && chown -R www-data.www-data \
        $APP_DIR $UPLOAD_DIR $SESSION_SAVE_PATH \
        $NGINX_USER_CONF_DIR $WWW_HOME $COMPOSER_HOME \
    && chmod 755 $UPLOAD_DIR $SESSION_SAVE_PATH $COMPOSER_HOME \
    # For easy access to php with `su www-data -c $CMD`
    && ln -sf ${PHP_DIR}/bin/php /usr/bin/php

# Put other config and shell files into place.
COPY nginx.conf fastcgi_params gzip_params "${NGINX_DIR}/"
COPY nginx-app.conf nginx-http.conf "${NGINX_USER_CONF_DIR}/"
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY entrypoint.sh composer.sh whitelist_functions.php /

RUN chgrp www-data composer.sh && \
    chmod +x /entrypoint.sh /composer.sh

# A script for extracting PHP version from composer.json.
COPY detect_php_version.php install_extensions.php /tmp/

WORKDIR $APP_DIR

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
