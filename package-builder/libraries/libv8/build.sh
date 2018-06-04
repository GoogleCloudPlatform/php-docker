#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building libv8"

PNAME="libv8"
VERSION=5.9.223

OUTPUT_FILE=${PNAME}_${VERSION}-1~gcp8+1_amd64.deb

if [ ! -f "${ARTIFACT_LIB_DIR}/${OUTPUT_FILE}" ]; then
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
    export PATH=`pwd`/depot_tools:"$PATH"

    # Download v8
    fetch v8
    pushd v8

    # (optional) If you'd like to build a certain version:
    git checkout ${VERSION}
    gclient sync

    cp -R ${DEB_BUILDER_DIR}/libraries/libv8/debian .

    dch --create -v "${VERSION}-1~gcp8+1" \
        --package ${PNAME} --empty -M \
        "Build ${VERSION}-1~gcp8+1 of ${PNAME}"
    dpkg-buildpackage -us -uc -j"$(nproc)"
    cp ../${OUTPUT_FILE} ${ARTIFACT_LIB_DIR}

    popd
fi
