#!/usr/bin/env bash
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

# A script for installing necessary software on CI systems.

set -ex

if [ "${INSTALL_PHP5}" == "true" ]; then
    sudo apt-get update
    sudo apt-get install -y php5-cli
fi

if [ "${INSTALL_GCLOUD}" == "true" ]; then
    # Install gcloud
    if [ ! -d ${HOME}/gcloud/google-cloud-sdk ]; then
        mkdir -p ${HOME}/gcloud &&
        wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz --directory-prefix=${HOME}/gcloud &&
        cd "${HOME}/gcloud" &&
            tar xzf google-cloud-sdk.tar.gz &&
            ./google-cloud-sdk/install.sh --usage-reporting false --path-update false --command-completion false &&
            cd "${TEST_BUILD_DIR}";
    fi
fi

if [ -z "${CLOUDSDK_ACTIVE_CONFIG_NAME}" ]; then
    echo "You need to set CLOUDSDK_ACTIVE_CONFIG_NAME envvar."
    exit 1
fi

if [ -z "${GOOGLE_PROJECT_ID}" ]; then
    echo "You need to set GOOGLE_PROJECT_ID envvar."
    exit 1
fi

if [ -z "${CLOUDSDK_VERBOSITY}" ]; then
    CLOUDSDK_VERBOSITY='none'
fi

# Install composer and defined dependencies
which composer || \
    (
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
        php -r "if (hash_file('SHA384', 'composer-setup.php') === rtrim(file_get_contents('https://composer.github.io/installer.sig'))) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
        sudo php composer-setup.php --filename=composer --install-dir=/usr/local/bin
    )
composer install --ignore-platform-reqs

# gcloud configurations
gcloud config configurations create ${CLOUDSDK_ACTIVE_CONFIG_NAME} || /bin/true # ignore failure
gcloud config set project ${GOOGLE_PROJECT_ID}
gcloud config set app/promote_by_default false
gcloud config set verbosity ${CLOUDSDK_VERBOSITY}

# Dump the credentials from the environment variable.
php scripts/dump_credentials.php

# Set the timeout
gcloud config set container/build_timeout 3600

if [ ! -f "${PHP_DOCKER_GOOGLE_CREDENTIALS}" ]; then
    echo 'Please set PHP_DOCKER_GOOGLE_CREDENTIALS envvar.'
    exit 1
fi


if [ "${CIRCLECI}" == "true" ]; then
    # Need sudo on circleci:
    # https://discuss.circleci.com/t/gcloud-components-update-version-restriction/3725
    # They also overrides the PATH to use
    # /opt/google-cloud-sdk/bin/gcloud so we can not easily use our
    # own gcloud
    sudo /opt/google-cloud-sdk/bin/gcloud -q components update beta
else
    gcloud -q components update beta
fi
