#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building libvips"

PNAME="libvips"
VERSION="8.5.7"

OUTPUT_FILE="${PNAME}_${VERSION}-1~gcp8+1_amd64.deb"

apt-get install -y libtiff5-dev libjpeg62-turbo-dev libgsf-1-dev

if [ ! -f "${ARTIFACT_DIR}/${OUTPUT_FILE}" ]; then
    # Download the source
    download_from_tarball https://github.com/jcupitt/libvips/releases/download/v${VERSION}/vips-${VERSION}.tar.gz ${VERSION}

    cp -R ${DEB_BUILDER_DIR}/extensions/libvips/debian ${PACKAGE_DIR}

    chmod +x ${PACKAGE_DIR}/debian/rules

    pushd ${PACKAGE_DIR}
    dch --create -v "${VERSION}" \
        --package ${PNAME} --empty -M \
        "Build ${VERSION} of ${PNAME}"
    dpkg-buildpackage -us -uc -j"$(nproc)"
    cp ../*.deb ${ARTIFACT_DIR}
    popd
fi
