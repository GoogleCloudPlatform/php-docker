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

set -ex

TAG="test-build"

# Dump the credentials from the environment variable.
php scripts/dump_credentials.php

if [ -f "${PHP_DOCKER_GOOGLE_CREDENTIALS}" ]; then
    # Use the service account for gcloud operations.
    gcloud auth activate-service-account \
        --key-file "${PHP_DOCKER_GOOGLE_CREDENTIALS}"
    # Set the timeout
    gcloud config set container/build_timeout 3600
fi

build_image () {
    if [ "$#" -ne 2 ]; then
        echo "Two arguments; the image name and the dir are required"
        exit 1
    fi
    IMAGE="${1}"
    DIR="${2}"
    if [ -f "${PHP_DOCKER_GOOGLE_CREDENTIALS}" ]; then
        # Build the image with container builder service if we have
        # credentials.
        FULL_TAG="gcr.io/${GOOGLE_PROJECT_ID}/${IMAGE}:${TAG}"
        gcloud -q alpha container builds create "${DIR}" --tag "${FULL_TAG}"
        gcloud docker pull "${FULL_TAG}"
        docker tag "${FULL_TAG}" "${IMAGE}"
    else
        # No credentials. Use local docker.
        docker build -t "${IMAGE}" "${DIR}"
    fi
}

build_image php-nginx php-nginx
build_image php56 testapps/php56
build_image php56_custom  testapps/php56_custom
build_image php70 testapps/php70
build_image php56_70 testapps/php56_70
build_image php70_custom testapps/php70_custom
build_image php56_nginx_conf testapps/php56_nginx_conf
build_image php56_custom_configs testapps/php56_custom_configs
