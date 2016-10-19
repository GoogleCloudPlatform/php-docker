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

# Dockerfile for PHP 5.6 using nginx as the webserver.

FROM php-base

# persistent / runtime deps
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
    cron \
    mercurial \
    subversion \
    supervisor

ENV NGINX_DIR=/opt/nginx \
    LOG_DIR=/var/log/app_engine \
    APP_DIR=/app \
    PHP_INI_SCAN_DIR=$APP_DIR: \
    NGINX_USER_CONF_DIR=/etc/nginx/conf.d \
    SESSION_SAVE_PATH=/tmp/sessions \
    NGINX_VERSION=1.10.1 \
    PATH=/opt/php/bin:$PATH \
    WWW_HOME=/var/www

# gpgkeys for verifying the tarballs
COPY gpgkeys/nginx /gpgkeys/nginx

# BUILD PHP, nginx and other dependencies.
COPY build-scripts/build_nginx.sh /build-scripts/build_nginx.sh

RUN /bin/bash /build-scripts/apt_build_deps.sh install && \
    /bin/bash /build-scripts/build_nginx.sh && \
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
COPY php-cli-strict.ini $PHP56_DIR/lib/
COPY php-cli-strict.ini $PHP7_DIR/lib/
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
