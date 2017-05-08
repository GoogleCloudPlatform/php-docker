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

DEFAULT_PHP_VERSION="7.1"

if [ -f ${APP_DIR}/composer.json ]; then
    # Extract php version from the composer.json.
    CMD="php /tmp/detect_php_version.php ${APP_DIR}/composer.json"
    PHP_VERSION=`su www-data -c "${CMD}"`

    # Remove files and directories for detecting PHP version.
    # These files are created in Dockerfile.
    rm -rf /tmp/vendor /tmp/detect_php_version.php /tmp/composer.*

    if [ "${PHP_VERSION}" != "5.6" ] && [ "${PHP_VERSION}" != "7.0" ] && [ "${PHP_VERSION}" != "7.1" ]; then
        cat<<EOF
There is no PHP runtime version specified in composer.json, or we don't support the version you specified. Google App Engine uses the latest 7.1.x version. We recommend pinning your PHP version by running:

composer require php 7.1.* (replace it with your desired minor version)

Using PHP version 7.1.x...
EOF
        PHP_VERSION=${DEFAULT_PHP_VERSION}
    fi

    if [ "${PHP_VERSION}" == "5.6" ]; then
        apt-get -y update
        /bin/bash /build-scripts/install_php56.sh
        apt-get remove -y gcp-php71
        rm -rf /var/lib/apt/lists/*
    fi

    if [ "${PHP_VERSION}" == "7.0" ]; then
        apt-get -y update
        /bin/bash /build-scripts/install_php70.sh
        apt-get remove -y gcp-php71
        rm -rf /var/lib/apt/lists/*
    fi

    # Handle custom oauth keys (Adapted from https://github.com/heroku/heroku-buildpack-php/blob/master/bin/compile)
    COMPOSER_GITHUB_OAUTH_TOKEN=${COMPOSER_GITHUB_OAUTH_TOKEN:-}
    if [[ -n "$COMPOSER_GITHUB_OAUTH_TOKEN" ]]; then
        if curl --fail --silent -H "Authorization: token $COMPOSER_GITHUB_OAUTH_TOKEN" https://api.github.com/rate_limit > /dev/null; then
            su www-data -c "php /usr/local/bin/composer \
              config -g github-oauth.github.com ${COMPOSER_GITHUB_OAUTH_TOKEN} &> /dev/null"
            # redirect outdated version warnings (Composer sends those to STDOUT instead of STDERR)
            echo 'Using $COMPOSER_GITHUB_OAUTH_TOKEN for GitHub OAuth.'
        else
            echo 'Invalid $COMPOSER_GITHUB_OAUTH_TOKEN for GitHub OAuth!'
        fi
    fi
    # no need for the token to stay around in the env
    unset COMPOSER_GITHUB_OAUTH_TOKEN

    # Workaround for https://github.com/docker/docker/issues/6047
    # We want to remove when Container Builder starts to use newer Docker.
    rm -rf ${APP_DIR}/vendor

    # Auto install extensions
    php -d auto_prepend_file='' /tmp/install_extensions.php ${APP_DIR}/composer.json ${PHP_DIR}/lib/conf.d/extensions.ini ${PHP_VERSION}

    # Run Composer.
    cd ${APP_DIR} && \
        su -m www-data -c "php -d auto_prepend_file='' /usr/local/bin/composer \
          install \
          --no-scripts \
          --no-dev \
          --prefer-dist \
          --optimize-autoloader \
          --no-interaction \
          --no-ansi \
          --no-progress"
fi
