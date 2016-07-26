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

TAG="rc"

# Dump the credentials from the environment variable.
php scripts/dump_credentials.php

if [ ! -f "${PHP_DOCKER_GOOGLE_CREDENTIALS}" ]; then
    # No credentials. Use local docker.
    docker build -t php-nginx php-nginx
else
    # Use the service account for gcloud operations.
    gcloud auth activate-service-account \
        --key-file "${PHP_DOCKER_GOOGLE_CREDENTIALS}"
    # Build the image with container builder service.
    gcloud alpha container builds create php-nginx \
        --tag "gcr.io/${GOOGLE_PROJECT_ID}/php-nginx:${TAG}"
    gcloud docker pull "gcr.io/${GOOGLE_PROJECT_ID}/php-nginx:${TAG}"
    docker tag \
        "gcr.io/${GOOGLE_PROJECT_ID}/php-nginx:${TAG}" php-nginx
fi

docker build -t php56 testapps/php56
docker build -t php56_custom testapps/php56_custom
docker build -t php70 testapps/php70
docker build -t php56_70 testapps/php56_70
docker build -t php70_custom testapps/php70_custom
docker build -t php56_nginx_conf testapps/php56_nginx_conf
docker build -t php56_custom_configs testapps/php56_custom_configs
