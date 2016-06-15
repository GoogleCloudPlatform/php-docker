#!/bin/sh
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

set -ex

sudo apt-get update
sudo apt-get install -y php5-cli

if [ -z "${CLOUDSDK_ACTIVE_CONFIG_NAME}" ]; then
    echo "You need to set CLOUDSDK_ACTIVE_CONFIG_NAME envvar."
    exit 1
fi

# Install composer and defined dependencies
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
composer install --ignore-platform-reqs

# Install gcloud
if [ ! -d ${HOME}/gcloud/google-cloud-sdk ]; then
    mkdir -p ${HOME}/gcloud &&
    wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz --directory-prefix=${HOME}/gcloud &&
    cd "${HOME}/gcloud" &&
    tar xzf google-cloud-sdk.tar.gz &&
    ./google-cloud-sdk/install.sh --usage-reporting false --path-update false --command-completion false &&
    cd "${TRAVIS_BUILD_DIR}";
fi

# gcloud configurations
gcloud config configurations create ${CLOUDSDK_ACTIVE_CONFIG_NAME} || /bin/true # ignore failure
gcloud -q components update app gsutil
gcloud config set project ${GOOGLE_PROJECT_ID}
gcloud config set app/promote_by_default false
