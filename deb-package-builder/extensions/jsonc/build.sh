#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/extensions/functions.sh

PNAME="gcp-php${SHORT_VERSION}-json"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    echo "Building json for gcp-php${SHORT_VERSION}"
    download_from_pecl jsonc
else
    echo "no need for building jsonc for gcp-php${SHORT_VERSION}"
    exit 0
fi

cp -R ${DEB_BUILDER_DIR}/extensions/jsonc/debian ${PACKAGE_DIR}

pushd ${PACKAGE_DIR}
dch --create -v "${EXT_VERSION}-${FULL_VERSION}" \
    --package ${PNAME} --empty -M \
    "Build ${EXT_VERSION}-${FULL_VERSION} of ${PNAME}"
dpkg-buildpackage -us -uc -j"$(nproc)"
popd
