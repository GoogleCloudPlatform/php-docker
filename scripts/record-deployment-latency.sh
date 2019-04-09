#!/bin/bash
set -ex
export KOKORO_GITHUB_DIR=${KOKORO_ROOT}/src/github
source ${KOKORO_GFILE_DIR}/kokoro/common.sh


cd ${KOKORO_GITHUB_DIR}/php-docker

gcloud config set project ${GOOGLE_PROJECT_ID}

scripts/record_deployment_latency.sh
