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

if [ -z "${RUNTIME_DISTRIBUTION}" ]; then
    RUNTIME_DISTRIBUTION="gcp-php-runtime-jessie"
fi

export RUNTIME_DISTRIBUTION
export PHP_BASE_IMAGE="gcr.io/${GOOGLE_PROJECT_ID}/php-base:${TAG}"
export BASE_IMAGE="gcr.io/${GOOGLE_PROJECT_ID}/php:${TAG}"
export PHP_56_IMAGE="gcr.io/${GOOGLE_PROJECT_ID}/php56:${TAG}"
export PHP_71_IMAGE="gcr.io/${GOOGLE_PROJECT_ID}/php71:${TAG}"

for TEMPLATE in `find . -name Dockerfile.in`
do
  envsubst '${BASE_IMAGE} ${PHP_BASE_IMAGE} ${PHP_71_IMAGE} ${PHP_56_IMAGE}' \
    < ${TEMPLATE} \
    > $(dirname ${TEMPLATE})/$(basename -s .in ${TEMPLATE})
done

gcloud container builds submit . \
  --config cloudbuild.yaml \
  --timeout 3600 \
  --substitutions _GOOGLE_PROJECT_ID=$GOOGLE_PROJECT_ID,_TAG=$TAG,_RUNTIME_DISTRIBUTION=$RUNTIME_DISTRIBUTION

if [ -z "${RUN_E2E_TESTS}" ]
then
    echo 'E2E test skipped'
else
    if [ -z "${E2E_PROJECT_ID}" ]
    then
        echo "Defaulting E2E_PROJECT_ID to GOOGLE_PROJECT_ID"
        E2E_PROJECT_ID=$GOOGLE_PROJECT_ID
    fi

    # replace runtime builder pipeline :latest with our newly tagged images
    sed -e "s/google-appengine/${GOOGLE_PROJECT_ID}/g" \
        -e "s/gcp-runtimes/${GOOGLE_PROJECT_ID}/g" \
        -e "/docker:latest/!s/:latest/:${TAG}/g" builder/php-latest.yaml > builder/php-test.yaml

    echo "Using test build pipeline:"
    cat builder/php-test.yaml

    gcloud container builds submit . \
      --config integration-tests.yaml \
      --timeout 3600 \
      --substitutions _GOOGLE_PROJECT_ID=$GOOGLE_PROJECT_ID,_TAG=$TAG,_SERVICE_ACCOUNT_JSON=$SERVICE_ACCOUNT_JSON,_E2E_PROJECT_ID=$E2E_PROJECT_ID,_RUNTIME_BUILDER_ROOT=file:///workspace/builder/,_TEST_VM_IMAGE=
fi
