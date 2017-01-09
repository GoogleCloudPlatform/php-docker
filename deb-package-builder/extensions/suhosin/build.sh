#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building suhosin for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-suhosin"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    EXT_VERSION=0.9.38
    PACKAGE_VERSION="${EXT_VERSION}-${PHP_VERSION}"
    PACKAGE_FULL_VERSION="${EXT_VERSION}-${FULL_VERSION}"
    PACKAGE_DIR=${PNAME}-${PACKAGE_VERSION}
    curl -SL "https://github.com/stefanesser/suhosin/archive/0.9.38.tar.gz" \
         -o ${PNAME}_${PACKAGE_VERSION}.orig.tar.gz
    mkdir -p ${PACKAGE_DIR}
    tar zxvf ${PNAME}_${PACKAGE_VERSION}.orig.tar.gz \
        -C ${PACKAGE_DIR} --strip-components=1
else
    echo "Not yet implemented"
    exit 0
fi

cp -R ${DEB_BUILDER_DIR}/extensions/suhosin/debian ${PACKAGE_DIR}

envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/rules.in \
         > ${PACKAGE_DIR}/debian/rules
chmod +x ${PACKAGE_DIR}/debian/rules
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/control.in \
         > ${PACKAGE_DIR}/debian/control
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/gcp-php-suhosin.install.in \
         > ${PACKAGE_DIR}/debian/gcp-php${SHORT_VERSION}-suhosin.install
rm ${PACKAGE_DIR}/debian/*.in
pushd ${PACKAGE_DIR}
dch --create -v "${EXT_VERSION}-${FULL_VERSION}" \
    --package ${PNAME} --empty -M \
    "Build ${EXT_VERSION}-${FULL_VERSION} of ${PNAME}"
dpkg-buildpackage -us -uc -j"$(nproc)"
popd
