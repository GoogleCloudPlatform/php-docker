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

# A script to run all the test locally and if all the test passes,
# deploy the image if PHP_DOCKER_DEPLOY envvar is set to 'true'.

# Run php-cs-fixer.
# We want to fail fast for coding standard violations.
if [ -z "${SKIP_CS_CHECK}" ]; then
    vendor/bin/php-cs-fixer fix --dry-run --diff
fi

# Build the ubuntu images
scripts/build_images.sh
