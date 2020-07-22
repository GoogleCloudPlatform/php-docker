#!/usr/bin/env bash
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

# This test runs our integration tests against our current production build pipeline and runtime.
set -ex

if [ -z "${TAG}" ]; then
    echo "You need to set TAG envvar."
    exit 1
fi

if [ -z "${GOOGLE_PROJECT_ID}" ]; then
    echo "You need to set GOOGLE_PROJECT_ID envvar."
    exit 1
fi

export PHP_BASE_IMAGE="gcr.io/google-appengine/php-base"
export BASE_IMAGE="gcr.io/google-appengine/php"
export PHP_71_IMAGE="gcr.io/google-appengine/php71"
export TEST_RUNNER_BASE_IMAGE=${PHP_71_IMAGE}

for TEMPLATE in `find . -name Dockerfile.in`
do
    envsubst '${BASE_IMAGE} ${PHP_BASE_IMAGE} ${PHP_71_IMAGE} ${TEST_RUNNER_BASE_IMAGE}' \
             < ${TEMPLATE} \
             > $(dirname ${TEMPLATE})/$(basename -s .in ${TEMPLATE})
done

if [ -z "${E2E_PROJECT_ID}" ]
then
    echo "Defaulting E2E_PROJECT_ID to GOOGLE_PROJECT_ID"
    E2E_PROJECT_ID=$GOOGLE_PROJECT_ID
fi

gcloud builds submit . \
  --config integration-tests.yaml \
  --timeout 3600 \
  --substitutions _GOOGLE_PROJECT_ID=$GOOGLE_PROJECT_ID,_TAG=$TAG,_SERVICE_ACCOUNT_JSON=$SERVICE_ACCOUNT_JSON,_E2E_PROJECT_ID=$E2E_PROJECT_ID,_TEST_VM_IMAGE=${TEST_VM_IMAGE},_RUNTIME_BUILDER_ROOT=
