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

# Uploads the image to gcr.io with a tag `testing`, and run e2e test.
# This file can be used directly for running e2e tests in local environment.

if [ -z "${GOOGLE_PROJECT_ID}" ]; then
    echo "Please set GOOGLE_PROJECT_ID env var to run the e2e test."
    exit 1
fi

if [ -z "${E2E_TEST_VERSION}" ]; then
    echo "Please set E2E_TEST_VERSION env var to run the e2e test."
    exit 1
fi

if [ ! -f "${PHP_DOCKER_GOOGLE_CREDENTIALS}" ]; then
    echo "The credentials file not found, skipping the e2e test."
    exit 0
fi

# Upload the local image to gcr.io with a tag `testing`.
docker tag -f \
    php-nginx gcr.io/${GOOGLE_PROJECT_ID}/php-nginx:${E2E_TEST_VERSION}
gcloud docker -- push gcr.io/${GOOGLE_PROJECT_ID}/php-nginx:${E2E_TEST_VERSION}
# Run e2e tests
vendor/bin/phpunit -c e2e.xml
