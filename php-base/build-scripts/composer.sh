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

if [ "${BUILDER_DEBUG_OUTPUT}" = "true" ]; then
    set -xe
else
    set -e
fi

DEFAULT_PHP_VERSION="7.4"

if [ -f ${APP_DIR}/composer.json ]; then
    if [ -n "${DETECTED_PHP_VERSION}" ]; then
        PHP_VERSION="${DETECTED_PHP_VERSION}"
    else
        echo "Detecting PHP version..."
        # Extract php version from the composer.json.
        CMD="php /build-scripts/detect_php_version.php ${APP_DIR}/composer.json"
        PHP_VERSION=`su www-data -c "${CMD}"`

        if [ "${PHP_VERSION}" == "exact" ]; then
            cat<<EOF
An exact PHP version was specified in composer.json. Please pin your PHP version to a minor version such as '7.4.*'.
EOF
            exit 1
        elif [ "${PHP_VERSION}" != "7.1" ] && [ "${PHP_VERSION}" != "7.2" ] && [ "${PHP_VERSION}" != "7.3" ] && [ "${PHP_VERSION}" != "7.4" ]; then
            cat<<EOF
There is no PHP runtime version specified in composer.json, or we don't support the version you specified. Google App Engine uses the latest 7.4.x version. We recommend pinning your PHP version by running:

composer require php 7.4.* (replace it with your desired minor version)

Using PHP version 7.4.x...
EOF
            PHP_VERSION=${DEFAULT_PHP_VERSION}
        fi

        if [ "${PHP_VERSION}" == "7.2" ]; then
            apt-get -y update
            /bin/bash /build-scripts/install_php72.sh
            apt-get remove -y gcp-php71
        elif [ "${PHP_VERSION}" == "7.3" ]; then
            apt-get -y update
            /bin/bash /build-scripts/install_php73.sh
            apt-get remove -y gcp-php71
        elif [ "${PHP_VERSION}" == "7.4" ]; then
            apt-get -y update
            /bin/bash /build-scripts/install_php74.sh
            apt-get remove -y gcp-php71
        fi
    fi

    echo "Using PHP version: ${PHP_VERSION}"

    # Workaround for https://github.com/docker/docker/issues/6047
    # We want to remove when Cloud Build starts to use newer Docker.
    rm -rf ${APP_DIR}/vendor

    echo "Install PHP extensions..."
    # Auto install extensions
    php -d auto_prepend_file='' /build-scripts/install_extensions.php ${APP_DIR}/composer.json ${PHP_DIR}/lib/conf.d/extensions.ini ${PHP_VERSION}
    /bin/bash /build-scripts/apt-cleanup.sh

    echo "Running composer..."
    # Run Composer.
    if [ -z "${COMPOSER_FLAGS}" ]; then
        COMPOSER_FLAGS='--no-scripts --no-dev --prefer-dist'
    fi
    cd ${APP_DIR} && \
        su -m www-data -c "php -d auto_prepend_file='' /usr/local/bin/composer \
          install \
          --optimize-autoloader \
          --no-interaction \
          --no-ansi \
          --no-progress \
          ${COMPOSER_FLAGS}"
fi
