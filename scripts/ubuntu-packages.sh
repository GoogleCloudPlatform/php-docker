#!/bin/bash
set -ex
source $KOKORO_PIPER_DIR/google3/third_party/runtimes_common/kokoro/common.sh
gcloud -q components update beta

cd $KOKORO_PIPER_DIR/google3/third_party/php_docker/package-builder

./build_packages.sh
