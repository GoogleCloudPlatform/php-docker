#!/bin/bash
set -ex
export KOKORO_GITHUB_DIR=${KOKORO_ROOT}/src/github
source ${KOKORO_GFILE_DIR}/kokoro/common.sh

gcloud -q components update beta

cd ${KOKORO_GITHUB_DIR}/php-docker

export TAG=`date +%Y-%m-%d-%H-%M`

cp "${PHP_DOCKER_GOOGLE_CREDENTIALS}" \
    ./service_account.json

# For nightly build
if [ "${GOOGLE_PROJECT_ID}" = "php-mvm-a-28051" ]; then
    gcloud config set project php-mvm-a-28051
fi

scripts/run_acceptance_tests.sh
