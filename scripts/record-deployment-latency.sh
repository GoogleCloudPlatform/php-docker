#!/bin/bash
set -ex
source $KOKORO_PIPER_DIR/google3/third_party/runtimes_common/kokoro/common.sh

cd $KOKORO_PIPER_DIR/google3/third_party/php_docker

gcloud config set project ${GOOGLE_PROJECT_ID}

scripts/record_deployment_latency.sh
