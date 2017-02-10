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

if [ -z "${TAG}" ]; then
    echo "You need to set TAG envvar."
    exit 1
fi

if [ -z "${GOOGLE_PROJECT_ID}" ]; then
    echo "You need to set GOOGLE_PROJECT_ID envvar."
    exit 1
fi

if [ -z "${SERVICE_ACCOUNT_JSON}" ]; then
    echo "You need to set SERVICE_ACCOUNT_JSON envvar pointing to a json file in GCS."
    exit 1
fi

if [ -z "${RUNTIME_DISTRIBUTION}" ]; then
    RUNTIME_DISTRIBUTION="gcp-php-runtime-jessie"
fi

export RUNTIME_DISTRIBUTION

# Dump the credentials from the environment variable.
php scripts/dump_credentials.php

if [ ! -f "${PHP_DOCKER_GOOGLE_CREDENTIALS}" ]; then
    echo 'Please set PHP_DOCKER_GOOGLE_CREDENTIALS envvar.'
    exit 1
fi

# Use the service account for gcloud operations.
gcloud auth activate-service-account \
    --key-file "${PHP_DOCKER_GOOGLE_CREDENTIALS}"

# Set the timeout
gcloud config set container/build_timeout 3600
SRC_TMP=$(mktemp -d)
export BASE_IMAGE="gcr.io/${GOOGLE_PROJECT_ID}/php-nginx:${TAG}"
# build the php test runner and export the name
export TEST_RUNNER="gcr.io/${GOOGLE_PROJECT_ID}/php-test-runner:${TAG}"
gcloud -q container builds submit --tag "${TEST_RUNNER}" \
    cloudbuild-test-runner

build_image () {
    if [ "$#" -ne 2 ]; then
        echo "Two arguments; the image name and the dir are required"
        exit 1
    fi
    DIR="${2}"
    # Build the image with container builder service if we have
    # credentials.
    export IMAGE="gcr.io/${GOOGLE_PROJECT_ID}/${1}:${TAG}"
    SRC_DIR="${SRC_TMP}/${DIR}"
    mkdir -p $(dirname ${SRC_DIR})
    cp -R "${DIR}" "${SRC_DIR}"
    # Replace the FROM line to point to our image in gcr.io.
    if [ -f "${SRC_DIR}/Dockerfile.in" ]; then
        envsubst '${BASE_IMAGE}' < "${SRC_DIR}/Dockerfile.in" \
                 > "${SRC_DIR}/Dockerfile"
    fi
    envsubst < "${SRC_DIR}/cloudbuild.yaml.in" > "${SRC_DIR}/cloudbuild.yaml"
    gcloud -q container builds submit "${SRC_DIR}" \
      --config "${SRC_DIR}"/cloudbuild.yaml
}

build_image php-nginx php-nginx
build_image php_default testapps/php_default
build_image php56 testapps/php56
build_image php56_custom  testapps/php56_custom
build_image php56_nginx_conf testapps/php56_nginx_conf
build_image php56_custom_configs testapps/php56_custom_configs
build_image php70_custom testapps/php70_custom
build_image php71_custom testapps/php71_custom
build_image php71_e2e testapps/php71_e2e
build_image create-dockerfile builder/create-dockerfile
