#!/usr/bin/env bash
# Copyright 2016 Google Inc.
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

export TEST_BUILD_DIR="${WORKSPACE}"
export HOME="${JENKINS_HOME}"
export GCLOUD_DIR="${HOME}/gcloud"
export GOOGLE_PROJECT_ID=php-mvm-a
export E2E_TEST_VERSION=jenkins-${BUILD_NUMBER}
export CLOUDSDK_CORE_DISABLE_PROMPTS=1
export PATH=${GCLOUD_DIR}/google-cloud-sdk/bin:${PATH}
export CLOUDSDK_ACTIVE_CONFIG_NAME=php-docker-e2e
export PHP_DOCKER_DEPLOY=true

gcloud info

scripts/run_test_suite.sh

unset CLOUDSDK_ACTIVE_CONFIG_NAME

IMAGE_NAME="gcr.io/${GOOGLE_PROJECT_ID}/php-nginx:${E2E_TEST_VERSION}"

CANDIDATE_TAG=`date +%Y-%m-%d_%H_%M`
echo "CANDIDATE_TAG:${CANDIDATE_TAG}"

PROD_IMAGE_NAME="gcr.io/${PRODUCTION_DOCKER_NAMESPACE}/php:${CANDIDATE_TAG}"

gcloud -q beta container images add-tag "${IMAGE_NAME}" "${PROD_IMAGE_NAME}"

# Push the image to staging if UPLOAD_TO_STAGING is true
if [ "${UPLOAD_TO_STAGING}" = "true" ]; then 
  STAGING="gcr.io/${PRODUCTION_DOCKER_NAMESPACE}/php:staging"
  gcloud -q beta container images add-tag "${PROD_IMAGE_NAME}" "${STAGING}"
fi
