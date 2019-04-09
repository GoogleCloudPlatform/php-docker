#!/bin/bash
set -ex
source $KOKORO_PIPER_DIR/google3/third_party/runtimes_common/kokoro/common.sh
gcloud -q components update beta

cd $KOKORO_PIPER_DIR/google3/third_party/php_docker

export TAG=`date +%Y-%m-%d-%H-%M`

cp "${KOKORO_ROOT}/src/keystore/72508_php_e2e_service_account" \
    ./service_account.json

# For nightly build
if [ "${GOOGLE_PROJECT_ID}" = "php-mvm-a" ]; then
    gcloud auth activate-service-account \
           --key-file="${KOKORO_ROOT}/src/keystore/72508_php_e2e_service_account"
    gcloud config set project php-mvm-a
fi

scripts/run_acceptance_tests.sh
