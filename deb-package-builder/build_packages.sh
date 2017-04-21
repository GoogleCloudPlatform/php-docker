#!/bin/bash

if [ -z "${GOOGLE_PROJECT_ID}" ]; then
    echo "You need to set GOOGLE_PROJECT_ID envvar."
    exit 1
fi

if [ -z "${PHP_VERSIONS}" ]; then
    PHP_VERSIONS='7.1.4-1,7.0.18-1,5.6.30-2'
    echo "Defaulting PHP Versions to: ${PHP_VERSIONS}"
fi

if [ -z "${BUCKET}" ]; then
    BUCKET=${GOOGLE_PROJECT_ID}
    echo "Defaulting Bucket to: ${BUCKET}"
fi

IMAGE="gcr.io/${GOOGLE_PROJECT_ID}/deb-package-builder"

# First, build the package builder
if [ -z "${USE_LATEST}" ]; then
    echo "Building package builder..."
    gcloud container builds submit . --config=builder.yaml \
                                     --substitutions _IMAGE=${IMAGE}
fi

# Use the package builder
for VERSION in $(echo ${PHP_VERSIONS} | tr "," "\n")
do
    echo "Building packages for PHP ${VERSION}"
    gcloud container builds submit . --config=build-packages.yaml \
                                     --substitutions _PHP_VERSION=${VERSION},_IMAGE=${IMAGE},_BUCKET=${BUCKET} \
                                     --timeout=30m
done
