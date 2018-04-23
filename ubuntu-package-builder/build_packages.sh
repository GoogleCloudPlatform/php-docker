#!/bin/bash
# Copyright 2017 Google Inc.
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

if [ -z "${GOOGLE_PROJECT_ID}" ]; then
    echo "You need to set GOOGLE_PROJECT_ID envvar."
    exit 1
fi

if [ -z "${PHP_VERSIONS}" ]; then
    PHP_VERSIONS='7.1.9-2,7.0.23-2,5.6.31-2,7.2.0RC1-2'
    echo "Defaulting PHP Versions to: ${PHP_VERSIONS}"
fi

if [ -z "${BUCKET}" ]; then
    BUCKET=${GOOGLE_PROJECT_ID}
    echo "Defaulting Bucket to: ${BUCKET}"
fi

# Use the package builder
for VERSION in $(echo ${PHP_VERSIONS} | tr "," "\n")
do
    echo "Building packages for PHP ${VERSION}"
    gcloud container builds submit . --config=build-packages.yaml \
                                     --substitutions _PHP_VERSION=${VERSION},_GOOGLE_PROJECT_ID=${GOOGLE_PROJECT_ID},_BUCKET=${BUCKET} \
                                     --timeout=180m
done
