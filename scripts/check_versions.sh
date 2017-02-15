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

if [ ! -f "${PHP_DOCKER_GOOGLE_CREDENTIALS}" ]; then
    echo 'Please set PHP_DOCKER_GOOGLE_CREDENTIALS envvar.'
    exit 1
fi

php scripts/dump_credentials.php

# Use the service account for gcloud operations.
gcloud auth activate-service-account \
    --key-file "${PHP_DOCKER_GOOGLE_CREDENTIALS}"

SRC_TMP=$(mktemp -d)

# build the php test runner and export the name
export TEST_RUNNER="gcr.io/${GOOGLE_PROJECT_ID}/php-test-runner:${TAG}"

gcloud -q container builds submit --tag "${TEST_RUNNER}" \
    cloudbuild-test-runner

SRC_DIR="${SRC_TMP}/check-versions"
cp -R check-versions ${SRC_DIR}
envsubst < "${SRC_DIR}/cloudbuild.yaml.in" > "${SRC_DIR}/cloudbuild.yaml"

gcloud -q container builds submit ${SRC_DIR} \
    --config "${SRC_DIR}/cloudbuild.yaml"
