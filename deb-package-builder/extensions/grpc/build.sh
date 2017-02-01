#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building grpc for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-grpc"

# Download the source
download_from_pecl grpc

rm ${PNAME}-${PACKAGE_VERSION}.orig.tar.gz
tar zcf ${PNAME}-${PACKAGE_VERSION}.orig.tar.gz ${PACKAGE_DIR}

cp -R ${DEB_BUILDER_DIR}/extensions/grpc/debian ${PACKAGE_DIR}

envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/rules.in \
         > ${PACKAGE_DIR}/debian/rules
chmod +x ${PACKAGE_DIR}/debian/rules
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/control.in \
         > ${PACKAGE_DIR}/debian/control
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/gcp-php-grpc.install.in \
         > ${PACKAGE_DIR}/debian/gcp-php${SHORT_VERSION}-grpc.install
rm ${PACKAGE_DIR}/debian/*.in
pushd ${PACKAGE_DIR}
dch --create -v "${EXT_VERSION}-${FULL_VERSION}" \
    --package ${PNAME} --empty -M \
    "Build ${EXT_VERSION}-${FULL_VERSION} of ${PNAME}"
dpkg-buildpackage -us -uc -j"$(nproc)"
popd
