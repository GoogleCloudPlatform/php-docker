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


# A shell script for installing dependencies with composer.
set -xe

DEFAULT_PHP_VERSION="5.6"

if [ -f ${APP_DIR}/composer.json ]; then
    # Extract php version from the composer.json.
    CMD="${PHP_DIR}/bin/php /tmp/detect_php_version.php ${APP_DIR}/composer.json"
    PHP_VERSION=`${CMD}`

    # Remove the vendor directory for the temporary script above.
    rm -rf /tmp/vendor

    if [ "${PHP_VERSION}" != "7.0" ] && [ "${PHP_VERSION}" != "5.6" ]; then
        cat<<EOF
There is no PHP runtime version specified in composer.json, or we don't support the version you specified. Google App Engine uses the latest stable version of PHP by default. We recommend pinning your PHP version by running:

composer require php ~5.6

Using PHP version 5.6.x...
EOF
        PHP_VERSION=${DEFAULT_PHP_VERSION}
    fi

    if [ "${PHP_VERSION}" == "7.0" ]; then
        rm ${PHP_DIR}
        ln -sf ${PHP7_DIR} ${PHP_DIR}
    fi

    if [ "${PHP_VERSION}" == "5.6" ]; then
        rm ${PHP_DIR}
        ln -sf ${PHP56_DIR} ${PHP_DIR}
    fi

    # Remove the vendor directory if it exists.
    if [ -d ${APP_DIR}/vendor ]; then
        rm -rf ${APP_DIR}/vendor
    fi
    # Run Composer.
    cd ${APP_DIR} && \
        ${PHP_DIR}/bin/php \
        -d suhosin.executor.include.whitelist=phar \
        -d suhosin.executor.func.blacklist=none \
        -d disable_functions= \
        /usr/local/bin/composer \
        install \
        --no-dev \
        --prefer-dist \
        --optimize-autoloader \
        --no-interaction
fi
