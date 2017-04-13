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
export E2E_PROJECT_ID=php-mvm-a
export CLOUDSDK_CORE_DISABLE_PROMPTS=1
export PATH=${GCLOUD_DIR}/google-cloud-sdk/bin:${PATH}
export CLOUDSDK_ACTIVE_CONFIG_NAME=php-docker-e2e
export SKIP_CS_CHECK=true
export INSTALL_GCLOUD=true
export BUILDER_TARGET_IMAGE="gcr.io/${PRODUCTION_DOCKER_NAMESPACE}/php"
export RUN_E2E_TESTS=true

if [ -z "${TAG}" ]; then
  TAG=`date +%Y-%m-%d-%H-%M`
fi

echo "CANDIDATE_TAG:${TAG}"
export TAG

gcloud info

scripts/install_test_dependencies.sh
scripts/run_test_suite.sh

unset CLOUDSDK_ACTIVE_CONFIG_NAME
