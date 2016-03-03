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

FROM gcr.io/google_appengine/base

# persistent / runtime deps
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
    cron \
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
    logrotate \
    mercurial \
    subversion \
    supervisor \
    zlib1g

ENV NGINX_DIR=/usr/local/nginx \
    PHP_DIR=/usr/local/php \
    PHP56_DIR=/usr/local/php56 \
    PHP7_DIR=/usr/local/php7 \
    LOG_DIR=/var/log/app_engine \
    APP_DIR=/app \
    NGINX_USER_CONF_DIR=/etc/nginx/conf.d \
    UPLOAD_DIR=/upload \
    SESSION_SAVE_PATH=/tmp/sessions \
    OPENSSL_VERSION=1.0.1p \
    PATH=/usr/local/php/bin:$PATH

# BUILD PHP, nginx and other dependencies.
COPY openssl-version-script.patch /tmp/openssl-version-script.patch

RUN mkdir /build-scripts

# Copy files one by one so we can leverage cache
COPY build-scripts/apt_build_deps.sh /build-scripts/apt_build_deps.sh
RUN /bin/bash /build-scripts/apt_build_deps.sh install

COPY build-scripts/import_pgp_keys.sh /build-scripts/import_pgp_keys.sh
RUN /bin/bash /build-scripts/import_pgp_keys.sh

# COPY build-scripts/build_openssl.sh /build-scripts/build_openssl.sh
# RUN /bin/bash /build-scripts/build_openssl.sh

# Build nginx
ENV NGINX_VERSION=1.8.1
COPY build-scripts/build_nginx.sh /build-scripts/build_nginx.sh
RUN /bin/bash /build-scripts/build_nginx.sh

# Build PHP 5.6
ENV PHP56_VERSION=5.6.19
COPY build-scripts/build_php56.sh /build-scripts/build_php56.sh
RUN /bin/bash /build-scripts/build_php56.sh

# Build PHP 7.0
ENV PHP70_VERSION=7.0.3
COPY build-scripts/build_php70.sh /build-scripts/build_php70.sh
RUN /bin/bash /build-scripts/build_php70.sh

RUN /bin/bash /build-scripts/apt_build_deps.sh uninstall

EXPOSE 8080

# Lock down the web directories
RUN mkdir -p $APP_DIR $LOG_DIR $UPLOAD_DIR $SESSION_SAVE_PATH \
        $NGINX_USER_CONF_DIR \
    && chown -R www-data.www-data \
        $APP_DIR $UPLOAD_DIR $SESSION_SAVE_PATH $LOG_DIR \
        $NGINX_USER_CONF_DIR \
    && chmod 755 $UPLOAD_DIR $SESSION_SAVE_PATH

# Put config files into place.
COPY nginx.conf fastcgi_params gzip_params $NGINX_DIR/conf/
COPY php.ini $PHP56_DIR/lib/php.ini
COPY php.ini $PHP7_DIR/lib/php.ini
COPY php-fpm.conf $PHP56_DIR/etc/php-fpm.conf
COPY php-fpm.conf $PHP7_DIR/etc/php-fpm.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY logrotate.app_engine /etc/logrotate.d/app_engine

# A script for dynamic configuration.
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# A script for installing dependencies.
COPY composer.sh /composer.sh
RUN chmod +x /composer.sh

# A script for extracting PHP version from composer.json.
COPY detect_php_version.php /tmp/detect_php_version.php
RUN cd /tmp && ${PHP_DIR}/bin/php \
        -d suhosin.executor.include.whitelist=phar \
        -d suhosin.executor.func.blacklist=none \
        /usr/local/bin/composer \
        require composer/semver

ONBUILD COPY . $APP_DIR
ONBUILD RUN chmod -R 550 $APP_DIR
ONBUILD RUN chown -R www-data.www-data $APP_DIR

WORKDIR $APP_DIR

ONBUILD RUN /composer.sh
# Now suhosin.log might be owned by root.
ONBUILD RUN touch $LOG_DIR/suhosin.log
ONBUILD RUN chown www-data.www-data $LOG_DIR/suhosin.log

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord"]
