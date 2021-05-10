#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building lirabbitmq"

PNAME="librabbitmq"
VERSION="0.11.0"

OUTPUT_FILE="${PNAME}_${VERSION}-1~gcp8+1_amd64.deb"

if [ ! -f "${ARTIFACT_LIB_DIR}/${OUTPUT_FILE}" ]; then
    # Download the source
    download_from_tarball https://github.com/alanxz/rabbitmq-c/archive/refs/tags/v${VERSION}.tar.gz ${VERSION}

    cp -R ${DEB_BUILDER_DIR}/libraries/${PNAME}/debian ./${PACKAGE_DIR}
    chmod +x ./${PACKAGE_DIR}/debian/rules

    SOURCEDIR=${BUILD_DIR}/${PACKAGE_DIR}
    INSTALL_PREFIX=${SOURCEDIR}/usr

    pushd ${PACKAGE_DIR}
    cmake \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
        ${SOURCE_DIR}

    cmake --build . --target install

    dch --create -v "${VERSION}-1~gcp8+1" \
        --package ${PNAME} --empty -M \
        "Build ${VERSION}-1~gcp8+1 of ${PNAME}"
    debuild -i -b -us -uc
    cp ../*.deb ${ARTIFACT_LIB_DIR}
    popd
fi
