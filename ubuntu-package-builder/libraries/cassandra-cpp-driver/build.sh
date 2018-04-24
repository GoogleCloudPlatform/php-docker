#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building cassandra cpp driver"

PNAME="cassandra-cpp-driver"
VERSION=2.7.0

OUTPUT_FILE="${PNAME}_${VERSION}-1~gcp8+1_amd64.deb"

if [ ! -f "${ARTIFACT_LIB_DIR}/${OUTPUT_FILE}" ]; then
    # Download the source
    download_from_tarball https://github.com/datastax/cpp-driver/archive/${VERSION}.tar.gz ${VERSION}
    PACKAGE_DIR=${PACKAGE_DIR}/packaging

    pushd ${PACKAGE_DIR}
    sed -i 's/libuv-dev/libuv1-dev/g' debian/control
    sed -i 's/release=1/release=1~gcp8+1/g' build_deb.sh
    ./build_deb.sh
    cp build/*.deb ${ARTIFACT_LIB_DIR}
    popd
fi
