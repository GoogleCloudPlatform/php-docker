#!/bin/bash
set -ex
export KOKORO_GITHUB_DIR=${KOKORO_ROOT}/src/github
source ${KOKORO_GFILE_DIR}/kokoro/common.sh

gcloud -q components update beta

cd ${KOKORO_GITHUB_DIR}/php-docker/package-builder

./build_packages.sh
