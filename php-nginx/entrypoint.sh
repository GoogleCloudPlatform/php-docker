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
if [ -n "${APP_NGINX_ADDITIONAL_CONF}" ]; then
    APP_NGINX_ADDITIONAL_CONF="${APP_DIR}/${APP_NGINX_ADDITIONAL_CONF}"
else
    APP_NGINX_ADDITIONAL_CONF="${APP_DIR}/nginx-app.conf"
fi

# App specific main configuration file. If this file exists, we
# replace our default main configuration file with this file.
if [ -n "${APP_NGINX_CONF}" ]; then
    APP_NGINX_CONF="${APP_DIR}/${APP_NGINX_CONF}"
else
    APP_NGINX_CONF="${APP_DIR}/nginx.conf"
fi

# Move user-provided nginx config files.
if [ -f "${APP_NGINX_ADDITIONAL_CONF}" ]; then
    mv "${APP_NGINX_ADDITIONAL_CONF}" "${NGINX_USER_CONF_DIR}"
fi

if [ -f "${APP_NGINX_CONF}" ]; then
    mv "${APP_NGINX_CONF}" "${NGINX_DIR}/conf/nginx.conf"
fi


# User provided php-fpm.conf
if [ -n "${APP_PHP_FPM_CONF}" ]; then
    APP_PHP_FPM_CONF="${APP_DIR}/${APP_PHP_FPM_CONF}"
else
    APP_PHP_FPM_CONF="${APP_DIR}/php-fpm.conf"
fi

# Move user-provided php-fpm config file.
if [ -f "${APP_PHP_FPM_CONF}" ]; then
    mv "${APP_PHP_FPM_CONF}" "${PHP_DIR}/etc/php-fpm-user.conf"
fi


# User provided php.ini
if [ -n "${APP_PHP_INI}" ]; then
    APP_PHP_INI="${APP_DIR}/${APP_PHP_INI}"
else
    APP_PHP_INI="${APP_DIR}/php.ini"
fi

# Move user-provided php.ini.
if [ -f "${APP_PHP_INI}" ]; then
    mv "${APP_PHP_INI}" "${PHP_DIR}/lib/conf.d"
fi


# User provided supervisord.conf
if [ -n "${APP_SUPERVISORD_CONF}" ]; then
    APP_SUPERVISORD_CONF="${APP_DIR}/${APP_SUPERVISORD_CONF}"
else
    APP_SUPERVISORD_CONF="${APP_DIR}/supervisord.conf"
fi

# Move user-provided supervisord.conf.
if [ -f "${APP_SUPERVISORD_CONF}" ]; then
    mv "${APP_SUPERVISORD_CONF}" /etc/supervisor/conf.d
fi


# Configure memcached based session.
if [ -n "${MEMCACHE_PORT_11211_TCP_ADDR}" ] && [ -n "${MEMCACHE_PORT_11211_TCP_PORT}" ]; then
    cat <<EOF > ${PHP_DIR}/lib/conf.d/memcached-session.ini
session.save_handler=memcached
session.save_path="${MEMCACHE_PORT_11211_TCP_ADDR}:${MEMCACHE_PORT_11211_TCP_PORT}"
EOF
fi

# Configure document root in php.ini and nginx.conf with DOCUMENT_ROOT
# environment variable or APP_DIR if DOCUMENT_ROOT is not set.

if [ -z "${DOCUMENT_ROOT}" ]; then
    DOCUMENT_ROOT="${APP_DIR}"
fi

sed -i "s|%%DOC_ROOT%%|${DOCUMENT_ROOT}|g" "${NGINX_DIR}/conf/nginx.conf"
sed -i "s|%%DOC_ROOT%%|${DOCUMENT_ROOT}|g" "${PHP_DIR}/lib/php.ini"

exec "$@"
