#!/bin/bash

# Copyright 2017 Google Inc.
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

if [ "${BUILDER_DEBUG_OUTPUT}" = "true" ]; then
    set -xe
else
    set -e
fi

echo "Moving user supplied config files..."

# App specific piece of the nginx config file included in the http section.
if [ -n "${NGINX_CONF_HTTP_INCLUDE}" ]; then
    NGINX_CONF_HTTP_INCLUDE="${APP_DIR}/${NGINX_CONF_HTTP_INCLUDE}"
else
    NGINX_CONF_HTTP_INCLUDE="${APP_DIR}/nginx-http.conf"
fi

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
    cp "${NGINX_CONF_INCLUDE}" "${NGINX_USER_CONF_DIR}/nginx-app.conf"
    chgrp www-data "${NGINX_USER_CONF_DIR}/nginx-app.conf"
fi

if [ -f "${NGINX_CONF_HTTP_INCLUDE}" ]; then
    cp "${NGINX_CONF_HTTP_INCLUDE}" "${NGINX_USER_CONF_DIR}/nginx-http.conf"
    chgrp www-data "${NGINX_USER_CONF_DIR}/nginx-http.conf"
fi

if [ -f "${NGINX_CONF_OVERRIDE}" ]; then
    cp "${NGINX_CONF_OVERRIDE}" "${NGINX_DIR}/nginx.conf"
    chgrp www-data "${NGINX_DIR}/nginx.conf"
fi

# User provided php-fpm.conf
if [ -n "${PHP_FPM_CONF_OVERRIDE}" ]; then
    PHP_FPM_CONF_OVERRIDE="${APP_DIR}/${PHP_FPM_CONF_OVERRIDE}"
else
    PHP_FPM_CONF_OVERRIDE="${APP_DIR}/php-fpm.conf"
fi

# Move user-provided php-fpm config file.
if [ -f "${PHP_FPM_CONF_OVERRIDE}" ]; then
    cp "${PHP_FPM_CONF_OVERRIDE}" "${PHP_DIR}/etc/php-fpm-user.conf"
    chgrp www-data "${PHP_DIR}/etc/php-fpm-user.conf"
fi

# User provided php.ini
if [ -n "${PHP_INI_OVERRIDE}" ]; then
    PHP_INI_OVERRIDE="${APP_DIR}/${PHP_INI_OVERRIDE}"
else
    PHP_INI_OVERRIDE="${APP_DIR}/php.ini"
fi

# Move user-provided php.ini.
if [ -f "${PHP_INI_OVERRIDE}" ]; then
    cp "${PHP_INI_OVERRIDE}" "${PHP_DIR}/lib/conf.d"
    chgrp www-data ${PHP_DIR}/lib/conf.d/*
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
    cp "${SUPERVISORD_CONF_ADDITION}" /etc/supervisor/conf.d
    chgrp www-data /etc/supervisor/conf.d/*
fi

if [ -f "${SUPERVISORD_CONF_OVERRIDE}" ]; then
    cp "${SUPERVISORD_CONF_OVERRIDE}" /etc/supervisor/supervisord.conf
    chgrp www-data /etc/supervisor/supervisord.conf
fi
