#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building libvips"

PNAME="libvips"
VERSION="8.5.7"

OUTPUT_FILE="${PNAME}_${VERSION}-1~gcp8+1_amd64.deb"

apt-get install -y libtiff5-dev libjpeg62-turbo-dev libgsf-1-dev

if [ ! -f "${ARTIFACT_LIB_DIR}/${OUTPUT_FILE}" ]; then
    # Download the source
    download_from_tarball https://github.com/jcupitt/libvips/releases/download/v${VERSION}/vips-${VERSION}.tar.gz ${VERSION}

    cp -R ${DEB_BUILDER_DIR}/libraries/libvips/debian ${PACKAGE_DIR}

    chmod +x ${PACKAGE_DIR}/debian/rules

    pushd ${PACKAGE_DIR}
    dch --create -v "${VERSION}-1~gcp8+1" \
        --package ${PNAME} --empty -M \
        "Build ${VERSION}-1~gcp8+1 of ${PNAME}"
    dpkg-buildpackage -us -uc -j"$(nproc)"
    cp ../*.deb ${ARTIFACT_LIB_DIR}
    popd
fi
