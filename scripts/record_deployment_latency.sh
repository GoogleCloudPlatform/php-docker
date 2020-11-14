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

if [ -z "${GOOGLE_PROJECT_ID}" ]; then
    echo 'Please set GOOGLE_PROJECT_ID envvar.'
    exit 1
fi

if [ -z "${GCLOUD_TRACK}" ]; then
    export GCLOUD_TRACK=ga
fi

if [ -z "${TAG}" ]; then
    export TAG=default
fi

TEST_RUNNER="gcr.io/${GOOGLE_PROJECT_ID}/php-test-runner:${TAG}"

if [ -n "${REBUILD_TEST_RUNNER}" ]; then
    # build the php test runner
    export TEST_RUNNER_BASE_IMAGE="gcr.io/google-appengine/php74:latest"
    envsubst '${TEST_RUNNER_BASE_IMAGE}' \
             < cloudbuild-test-runner/Dockerfile.in \
             > cloudbuild-test-runner/Dockerfile
    gcloud -q builds submit --tag "${TEST_RUNNER}" \
           cloudbuild-test-runner
fi

gcloud -q builds submit perf-dashboard/deployment-latency\
       --timeout 7200 \
       --config perf-dashboard/deployment-latency/cloudbuild.yaml \
       --substitutions _TEST_RUNNER="${TEST_RUNNER}",_GCLOUD_TRACK="${GCLOUD_TRACK}",_GOOGLE_PROJECT_ID=${GOOGLE_PROJECT_ID}
