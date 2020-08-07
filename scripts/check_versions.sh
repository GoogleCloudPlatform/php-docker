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

php scripts/dump_credentials.php

if [ ! -f "${PHP_DOCKER_GOOGLE_CREDENTIALS}" ]; then
    echo 'Please set PHP_DOCKER_GOOGLE_CREDENTIALS envvar.'
    exit 1
fi

SRC_TMP=$(mktemp -d)

# build the php test runner
export TEST_RUNNER_BASE_IMAGE="gcr.io/google-appengine/php71:latest"
envsubst '${TEST_RUNNER_BASE_IMAGE}' \
         < cloudbuild-test-runner/Dockerfile.in \
         > cloudbuild-test-runner/Dockerfile

TEST_RUNNER="gcr.io/${GOOGLE_PROJECT_ID}/php-test-runner:${TAG}"

gcloud -q builds submit --tag "${TEST_RUNNER}" \
    cloudbuild-test-runner

# Check the version
gcloud -q builds submit check-versions \
       --config check-versions/cloudbuild.yaml \
       --substitutions _TEST_RUNNER="${TEST_RUNNER}"

