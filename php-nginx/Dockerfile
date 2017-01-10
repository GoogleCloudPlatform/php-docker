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

# Cache busting for security update
ENV UPDATED_AT 2016-11-15

RUN apt-get update -y && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
    cron \
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
    logrotate \
    mercurial \
    sasl2-bin \
    subversion \
    supervisor \
    zlib1g

ENV NGINX_DIR=/opt/nginx \
    PHP_DIR=/opt/php \
    PHP56_DIR=/opt/php56 \
    PHP70_DIR=/opt/php70 \
    LOG_DIR=/var/log/app_engine \
    APP_DIR=/app \
    NGINX_USER_CONF_DIR=/etc/nginx/conf.d \
    UPLOAD_DIR=/upload \
    SESSION_SAVE_PATH=/tmp/sessions \
    NGINX_VERSION=1.10.2 \
    PHP56_VERSION=5.6.29 \
    PHP70_VERSION=7.0.14 \
    PATH=/opt/php/bin:$PATH \
    WWW_HOME=/var/www

# gpgkeys for verifying the tarballs
COPY gpgkeys /gpgkeys

# BUILD PHP, nginx and other dependencies.
COPY build-scripts /build-scripts

ARG RUNTIME_DISTRIBUTION="gcp-php-runtime-jessie"

RUN (echo "deb http://packages.cloud.google.com/apt ${RUNTIME_DISTRIBUTION} main" \
    | tee /etc/apt/sources.list.d/gcp-php-runtime-jessie.list) && \
    (curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
      | apt-key add -) && \
    apt-get -y update && \
    /bin/bash /build-scripts/apt_build_deps.sh install && \
    /bin/bash /build-scripts/build_nginx.sh && \
    /bin/bash /build-scripts/install_php56.sh && \
    /bin/bash /build-scripts/install_php70.sh && \
    /bin/bash /build-scripts/apt_build_deps.sh uninstall

EXPOSE 8080

# Lock down the web directories
RUN mkdir -p $APP_DIR $LOG_DIR $UPLOAD_DIR $SESSION_SAVE_PATH \
        $NGINX_USER_CONF_DIR $WWW_HOME\
    && chown -R www-data.www-data \
        $APP_DIR $UPLOAD_DIR $SESSION_SAVE_PATH $LOG_DIR \
        $NGINX_USER_CONF_DIR $WWW_HOME \
    && chmod 755 $UPLOAD_DIR $SESSION_SAVE_PATH \
    # For easy access to php with `su www-data -c $CMD`
    && ln -sf ${PHP_DIR}/bin/php /usr/bin/php

# Put config files into place.
COPY nginx.conf fastcgi_params gzip_params $NGINX_DIR/conf/
COPY nginx-app.conf $NGINX_USER_CONF_DIR
COPY php-fpm.conf $PHP56_DIR/etc/php-fpm.conf
COPY php-fpm.conf $PHP70_DIR/etc/php-fpm.conf
RUN touch $PHP56_DIR/etc/php-fpm-user.conf $PHP70_DIR/etc/php-fpm-user.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY logrotate.app_engine /etc/logrotate.d/app_engine

COPY entrypoint.sh composer.sh whitelist_functions.php /

RUN chgrp www-data composer.sh && chmod +x /entrypoint.sh /composer.sh \
    # Temporary enable the shell for www-data
    # We will disable it in entrypoint.sh
    && chsh -s /bin/bash www-data

# A script for extracting PHP version from composer.json.
COPY detect_php_version.php /tmp/detect_php_version.php
RUN chgrp www-data /tmp/detect_php_version.php && cd /tmp \
    && su www-data -c "php /usr/local/bin/composer require composer/semver"

# Copy the app and change the owner
ONBUILD COPY . $APP_DIR
ONBUILD RUN chown -R www-data.www-data $APP_DIR

WORKDIR $APP_DIR

ONBUILD RUN /composer.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord"]
