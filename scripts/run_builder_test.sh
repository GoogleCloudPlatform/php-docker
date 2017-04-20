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

set -ex

if [ -z "${TAG}" ]; then
    echo "You need to set TAG envvar."
    exit 1
fi

if [ -z "${GOOGLE_PROJECT_ID}" ]; then
    echo "You need to set GOOGLE_PROJECT_ID envvar."
    exit 1
fi

# Export some image names
export GEN_DOCKERFILE="gcr.io/${GOOGLE_PROJECT_ID}/php/gen-dockerfile:${TAG}"
export TEST_RUNNER="gcr.io/${GOOGLE_PROJECT_ID}/php-test-runner:${TAG}"

SRC_TMP=$(mktemp -d)
DIR=testapps/builder_test
SRC_DIR="${SRC_TMP}/${DIR}"
mkdir -p $(dirname ${SRC_DIR})
cp -R "${DIR}" "${SRC_DIR}"

envsubst '{$GEN_DOCKERFILE},${TEST_RUNNER}' \
         < "${SRC_DIR}/cloudbuild.yaml.in" \
         > "${SRC_DIR}/cloudbuild.yaml"

gcloud -q beta container builds submit "${SRC_DIR}" \
      --config "${SRC_DIR}/cloudbuild.yaml"
