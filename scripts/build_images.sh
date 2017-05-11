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

SRC_TMP=$(mktemp -d)
export PHP_BASE_IMAGE="gcr.io/${GOOGLE_PROJECT_ID}/php-base:${TAG}"
export BASE_IMAGE="gcr.io/${GOOGLE_PROJECT_ID}/php:${TAG}"

for TEMPLATE in `find . -name Dockerfile.in`
do
  envsubst '${BASE_IMAGE}' < ${TEMPLATE} > $(dirname ${TEMPLATE})/$(basename -s .in ${TEMPLATE})
done
envsubst '${BASE_IMAGE} ${PHP_BASE_IMAGE}' < php-onbuild/Dockerfile.in > php-onbuild/Dockerfile
envsubst '${BASE_IMAGE} ${PHP_BASE_IMAGE}' < builder/gen-dockerfile/Dockerfile.in > builder/gen-dockerfile/Dockerfile

gcloud container builds submit . \
  --config cloudbuild.yaml \
  --timeout 3600 \
  --substitutions _TAG=$TAG,_RUNTIME_DISTRIBUTION=$RUNTIME_DISTRIBUTION
