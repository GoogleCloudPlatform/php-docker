#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building apcu_bc for gcp-php${SHORT_VERSION}"


PNAME="gcp-php${SHORT_VERSION}-apcu-bc"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    echo 'No need to build apcu_bc'
    exit 0
else
    # We need to install the build dep
    dpkg -i ${BUILD_DIR}/gcp-php${SHORT_VERSION}-apcu*.deb
    pecl download apcu_bc-beta
    EXT_VERSION=$(ls apcu_bc-*.tgz | \
            sed "s/apcu_bc-\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)\.tgz/\1/")
    PACKAGE_VERSION="${EXT_VERSION}-${PHP_VERSION}"
    PACKAGE_FULL_VERSION="${EXT_VERSION}-${FULL_VERSION}"
    PACKAGE_DIR=${PNAME}-${PACKAGE_VERSION}
    mv apcu_bc-${EXT_VERSION}.tgz \
       ${PNAME}_${PACKAGE_VERSION}.orig.tar.gz
    mkdir -p ${PACKAGE_DIR}
    tar zxvf ${PNAME}_${PACKAGE_VERSION}.orig.tar.gz \
        -C ${PACKAGE_DIR} --strip-components=1
fi

cp -R ${DEB_BUILDER_DIR}/extensions/apcu_bc/debian ${PACKAGE_DIR}

envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/rules.in \
         > ${PACKAGE_DIR}/debian/rules
chmod +x ${PACKAGE_DIR}/debian/rules
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/control.in \
         > ${PACKAGE_DIR}/debian/control
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/gcp-php-apcu-bc.install.in \
         > ${PACKAGE_DIR}/debian/gcp-php${SHORT_VERSION}-apcu-bc.install
rm ${PACKAGE_DIR}/debian/*.in
pushd ${PACKAGE_DIR}
dch --create -v "${EXT_VERSION}-${FULL_VERSION}" \
    --package ${PNAME} --empty -M \
    "Build ${EXT_VERSION}-${FULL_VERSION} of ${PNAME}"
dpkg-buildpackage -us -uc -j"$(nproc)"
popd
