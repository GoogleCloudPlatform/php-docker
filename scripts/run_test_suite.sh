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

# A script to run all the test locally and if all the test passes,
# deploy the image if PHP_DOCKER_DEPLOY envvar is set to 'true'.

# Run php-cs-fixer.
# We want to fail fast for coding standard violations.
vendor/bin/php-cs-fixer fix --dry-run --diff .

# Then build images.
scripts/build_images.sh

# Run functional tests.
vendor/bin/phpunit

# Run e2e tests.
scripts/run_e2e_tests.sh

# Deploy the newly built image to gcr.io if PHP_DOCKER_DEPLOY envvar is true.
if [ "${PHP_DOCKER_DEPLOY}" = "true" ]; then
    # If we are on travis, skip for pull requests, only deploy on master push.
    if [ "${TRAVIS}" == "true" ]; then
        if [ "${TRAVIS_PULL_REQUEST}" = "true" ] ||
            [ "${TRAVIS_BRANCH}" != "master" ]
        then
            echo "We only deploy on master push."
            exit 0
        fi
    fi
    echo "Deploying the new image."
    scripts/deploy_image.sh
else
    echo "We only deploy the image when PHP_DOCKER_DEPLOY envvar is 'true'."
fi
