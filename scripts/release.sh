#!/bin/bash
set -ex
source $KOKORO_GFILE_DIR/common.sh
gcloud -q components update beta

cd github/php-docker

if [ -z "$TAG" ]
then
  export TAG=$(date +%Y-%m-%d-%H-%M)
fi
export CANDIDATE_TAG=${TAG}

cp "${KOKORO_ROOT}/src/keystore/72508_php_e2e_service_account" \
    ./service_account.json

# For nightly build
if [ "${GOOGLE_PROJECT_ID}" = "php-mvm-a" ]; then
    gcloud auth activate-service-account \
           --key-file="${KOKORO_ROOT}/src/keystore/72508_php_e2e_service_account"
fi
gcloud config set project ${GOOGLE_PROJECT_ID}

scripts/build_images.sh

IMAGE_NAME="gcr.io/${GOOGLE_PROJECT_ID}/php:${TAG}"
BASE_IMAGE_NAME="gcr.io/${GOOGLE_PROJECT_ID}/php-base:${TAG}"
PHP72_IMAGE_NAME="gcr.io/${GOOGLE_PROJECT_ID}/php72:${TAG}"
PHP71_IMAGE_NAME="gcr.io/${GOOGLE_PROJECT_ID}/php71:${TAG}"
PHP70_IMAGE_NAME="gcr.io/${GOOGLE_PROJECT_ID}/php70:${TAG}"
PHP56_IMAGE_NAME="gcr.io/${GOOGLE_PROJECT_ID}/php56:${TAG}"
BUILDER_IMAGE_NAME="gcr.io/${GOOGLE_PROJECT_ID}/php/gen-dockerfile:${TAG}"

if [ "${ADD_CANDIDATE_TAG}" = "true" ]; then
    echo "CANDIDATE_TAG:${CANDIDATE_TAG}"
    gcloud -q beta container images add-tag "${IMAGE_NAME}" "${DOCKER_NAMESPACE}/php:${CANDIDATE_TAG}"
    gcloud -q beta container images add-tag "${BASE_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php-base:${CANDIDATE_TAG}"
    gcloud -q beta container images add-tag "${PHP72_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php72:${CANDIDATE_TAG}"
    gcloud -q beta container images add-tag "${PHP71_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php71:${CANDIDATE_TAG}"
    gcloud -q beta container images add-tag "${PHP70_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php70:${CANDIDATE_TAG}"
    gcloud -q beta container images add-tag "${PHP56_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php56:${CANDIDATE_TAG}"
fi


if [ "${ADD_STAGING_TAG}" = "true" ]; then
    gcloud -q beta container images add-tag "${IMAGE_NAME}" "${DOCKER_NAMESPACE}/php:staging"
    gcloud -q beta container images add-tag "${BASE_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php-base:staging"
    gcloud -q beta container images add-tag "${PHP72_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php72:staging"
    gcloud -q beta container images add-tag "${PHP71_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php71:staging"
    gcloud -q beta container images add-tag "${PHP70_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php70:staging"
    gcloud -q beta container images add-tag "${PHP56_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php56:staging"
    gcloud -q beta container images add-tag "${BUILDER_IMAGE_NAME}" "${BUILDER_DOCKER_NAMESPACE}/php/gen-dockerfile:staging"
fi

METADATA=$(pwd)/METADATA
cd $KOKORO_PIPER_DIR/google3/third_party/runtimes_common/kokoro
python note.py php -m ${METADATA} -t ${TAG}
python note.py php-base -m ${METADATA} -t ${TAG}
python note.py php72 -m ${METADATA} -t ${TAG}
python note.py php71 -m ${METADATA} -t ${TAG}
python note.py php70 -m ${METADATA} -t ${TAG}
python note.py php56 -m ${METADATA} -t ${TAG}
