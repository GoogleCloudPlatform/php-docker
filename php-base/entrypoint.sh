#!/bin/bash

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


# This file configure the runtime dynamically based on the contents
# and environment variables that user provides.

set -xe

# App specific piece of the config file which is included from the
# main configuration file.
if [ -n "${NGINX_CONF_INCLUDE}" ]; then
    NGINX_CONF_INCLUDE="${APP_DIR}/${NGINX_CONF_INCLUDE}"
else
    NGINX_CONF_INCLUDE="${APP_DIR}/nginx-app.conf"
fi

# App specific main configuration file. If this file exists, we
# replace our default main configuration file with this file.
if [ -n "${NGINX_CONF_OVERRIDE}" ]; then
    NGINX_CONF_OVERRIDE="${APP_DIR}/${NGINX_CONF_OVERRIDE}"
else
    NGINX_CONF_OVERRIDE="${APP_DIR}/nginx.conf"
fi

# Move user-provided nginx config files.
if [ -f "${NGINX_CONF_INCLUDE}" ]; then
    mv "${NGINX_CONF_INCLUDE}" "${NGINX_USER_CONF_DIR}"
fi

if [ -f "${NGINX_CONF_OVERRIDE}" ]; then
    mv "${NGINX_CONF_OVERRIDE}" "${NGINX_DIR}/nginx.conf"
fi

# User provided php-fpm.conf
if [ -n "${PHP_FPM_CONF_OVERRIDE}" ]; then
    PHP_FPM_CONF_OVERRIDE="${APP_DIR}/${PHP_FPM_CONF_OVERRIDE}"
else
    PHP_FPM_CONF_OVERRIDE="${APP_DIR}/php-fpm.conf"
fi

# Move user-provided php-fpm config file.
if [ -f "${PHP_FPM_CONF_OVERRIDE}" ]; then
    mv "${PHP_FPM_CONF_OVERRIDE}" "${PHP_DIR}/etc/php-fpm-user.conf"
fi

# User provided php.ini
if [ -n "${PHP_INI_OVERRIDE}" ]; then
    PHP_INI_OVERRIDE="${APP_DIR}/${PHP_INI_OVERRIDE}"
else
    PHP_INI_OVERRIDE="${APP_DIR}/php.ini"
fi

# Move user-provided php.ini.
if [ -f "${PHP_INI_OVERRIDE}" ]; then
    mv "${PHP_INI_OVERRIDE}" "${PHP_DIR}/lib/conf.d"
fi

# User provided supervisord.conf
if [ -n "${SUPERVISORD_CONF_ADDITION}" ]; then
    SUPERVISORD_CONF_ADDITION="${APP_DIR}/${SUPERVISORD_CONF_ADDITION}"
else
    SUPERVISORD_CONF_ADDITION="${APP_DIR}/additional-supervisord.conf"
fi

if [ -n "${SUPERVISORD_CONF_OVERRIDE}" ]; then
    SUPERVISORD_CONF_OVERRIDE="${APP_DIR}/${SUPERVISORD_CONF_OVERRIDE}"
else
    SUPERVISORD_CONF_OVERRIDE="${APP_DIR}/supervisord.conf"
fi

# Move user-provided supervisord.conf.
if [ -f "${SUPERVISORD_CONF_ADDITION}" ]; then
    mv "${SUPERVISORD_CONF_ADDITION}" /etc/supervisor/conf.d
fi

if [ -f "${SUPERVISORD_CONF_OVERRIDE}" ]; then
    mv "${SUPERVISORD_CONF_OVERRIDE}" /etc/supervisor/supervisord.conf
fi

# Configure memcached based session.
if [ -n "${MEMCACHE_PORT_11211_TCP_ADDR}" ] && [ -n "${MEMCACHE_PORT_11211_TCP_PORT}" ]; then
    cat <<EOF > ${PHP_DIR}/lib/conf.d/memcached-session.ini
session.save_handler=memcached
session.save_path="${MEMCACHE_PORT_11211_TCP_ADDR}:${MEMCACHE_PORT_11211_TCP_PORT}"
EOF
fi

if [ -f "${APP_DIR}/composer.json" ]; then
    # run the composer scripts for post-deploy
    if su www-data -c "php /usr/local/bin/composer --no-ansi run-script -l" \
        | grep -q "post-deploy-cmd"; then
        su www-data -c \
            "php /usr/local/bin/composer run-script post-deploy-cmd \
            --no-ansi \
            --no-interaction" \
            || (echo 'Failed to execute post-deploy-cmd'; exit 1)
    fi
fi

# Lock down the DOCUMENT_ROOT
chown -R root.www-data ${DOCUMENT_ROOT}
chmod -R 550 ${DOCUMENT_ROOT}

# Change the www-data's shell back to /usr/sbin/nologin
chsh -s /usr/sbin/nologin www-data

# Enable suhosin for PHP 5.6.x
if [ -x "${PHP56_DIR}/bin/php56-enmod" ]; then
    ${PHP56_DIR}/bin/php56-enmod suhosin
fi

# Whitelist functions
${PHP_DIR}/bin/php -d auto_prepend_file='' /whitelist_functions.php

# Remove loose php-cli.ini
rm /opt/php/lib/php-cli.ini

exec "$@"
