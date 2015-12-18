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

# Dump the service account file from a secret envvar on travis.
if [ "${TRAVIS}" = "true" ]; then
    if [ "${TRAVIS_SECURE_ENV_VARS}" = "false" ]; then
        # This must be a pull request from other repository.
        # Skipping all of the following.
        echo "Skipping e2e test for pull requests from other repo."
        exit 0
    fi
    # Dump the credentials from the environment variable.
    php scripts/dump_credentials.php

fi

if [ -f "${PHP_DOCKER_GOOGLE_CREDENTIALS}" ]; then
    # Use the service account for gcloud operations.
    gcloud auth activate-service-account \
        --key-file "${PHP_DOCKER_GOOGLE_CREDENTIALS}"
fi

# Upload the local image to gcr.io with a tag `testing`.
docker tag -f \
    php-nginx gcr.io/${GOOGLE_PROJECT_ID}/php-nginx:${E2E_TEST_VERSION}
gcloud docker push gcr.io/${GOOGLE_PROJECT_ID}/php-nginx:${E2E_TEST_VERSION}

# Run e2e tests
vendor/bin/phpunit -c e2e.xml
