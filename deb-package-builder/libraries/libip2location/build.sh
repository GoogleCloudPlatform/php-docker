#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building libip2location"

PNAME="libip2location"
VERSION="8.0.7"

OUTPUT_FILE="${PNAME}_${VERSION}-1~gcp8+1_amd64.deb"


if [ ! -f "${ARTIFACT_LIB_DIR}/${OUTPUT_FILE}" ]; then
    # Download the source
    # https://github.com/chrislim2888/IP2Location-C-Library/archive/8.0.7.tar.gz
    download_from_tarball https://github.com/chrislim2888/IP2Location-C-Library/archive/${VERSION}.tar.gz ${VERSION}

    cp -R ${DEB_BUILDER_DIR}/libraries/libip2location/debian ${PACKAGE_DIR}

    chmod +x ${PACKAGE_DIR}/debian/rules

    pushd ${PACKAGE_DIR}
    cp README.md README
    dch --create -v "${VERSION}-1~gcp8+1" \
        --package ${PNAME} --empty -M \
        "Build ${VERSION}-1~gcp8+1 of ${PNAME}"
    dpkg-buildpackage -us -uc -j"$(nproc)"
    cp ../*.deb ${ARTIFACT_LIB_DIR}
    popd
fi
