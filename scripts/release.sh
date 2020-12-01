#!/bin/bash
set -ex
export KOKORO_GITHUB_DIR=${KOKORO_ROOT}/src/github
source ${KOKORO_GFILE_DIR}/kokoro/common.sh

gcloud -q components update beta

cd ${KOKORO_GITHUB_DIR}/php-docker

if [ -z "$TAG" ]
then
  export TAG=$(date +%Y-%m-%d-%H-%M)
fi
export CANDIDATE_TAG=${TAG}

gcloud config set project ${GOOGLE_PROJECT_ID}

scripts/build_images.sh

IMAGE_NAME="gcr.io/${GOOGLE_PROJECT_ID}/php:${TAG}"
BASE_IMAGE_NAME="gcr.io/${GOOGLE_PROJECT_ID}/php-base:${TAG}"
PHP74_IMAGE_NAME="gcr.io/${GOOGLE_PROJECT_ID}/php74:${TAG}"
PHP73_IMAGE_NAME="gcr.io/${GOOGLE_PROJECT_ID}/php73:${TAG}"
PHP72_IMAGE_NAME="gcr.io/${GOOGLE_PROJECT_ID}/php72:${TAG}"
PHP71_IMAGE_NAME="gcr.io/${GOOGLE_PROJECT_ID}/php71:${TAG}"
BUILDER_IMAGE_NAME="gcr.io/${GOOGLE_PROJECT_ID}/php/gen-dockerfile:${TAG}"

if [ "${ADD_CANDIDATE_TAG}" = "true" ]; then
    echo "CANDIDATE_TAG:${CANDIDATE_TAG}"
    gcloud -q beta container images add-tag "${IMAGE_NAME}" "${DOCKER_NAMESPACE}/php:${CANDIDATE_TAG}"
    gcloud -q beta container images add-tag "${BASE_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php-base:${CANDIDATE_TAG}"
    gcloud -q beta container images add-tag "${PHP74_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php74:${CANDIDATE_TAG}"
    gcloud -q beta container images add-tag "${PHP73_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php73:${CANDIDATE_TAG}"
    gcloud -q beta container images add-tag "${PHP72_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php72:${CANDIDATE_TAG}"
    gcloud -q beta container images add-tag "${PHP71_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php71:${CANDIDATE_TAG}"
fi


if [ "${ADD_STAGING_TAG}" = "true" ]; then
    gcloud -q beta container images add-tag "${IMAGE_NAME}" "${DOCKER_NAMESPACE}/php:staging"
    gcloud -q beta container images add-tag "${BASE_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php-base:staging"
    gcloud -q beta container images add-tag "${PHP74_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php74:staging"
    gcloud -q beta container images add-tag "${PHP73_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php73:staging"
    gcloud -q beta container images add-tag "${PHP72_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php72:staging"
    gcloud -q beta container images add-tag "${PHP71_IMAGE_NAME}" "${DOCKER_NAMESPACE}/php71:staging"
    gcloud -q beta container images add-tag "${BUILDER_IMAGE_NAME}" "${BUILDER_DOCKER_NAMESPACE}/php/gen-dockerfile:staging"
fi

METADATA=$(pwd)/METADATA
cd ${KOKORO_GFILE_DIR}/kokoro
python note.py php -m ${METADATA} -t ${TAG}
python note.py php-base -m ${METADATA} -t ${TAG}
python note.py php74 -m ${METADATA} -t ${TAG}
python note.py php73 -m ${METADATA} -t ${TAG}
python note.py php72 -m ${METADATA} -t ${TAG}
python note.py php71 -m ${METADATA} -t ${TAG}
