#!/bin/bash

# common functions for building extensions

E_PARAM_ERR=250

with_retry()
{
    # Execute command up to x times
    # Usage:
    # with_retry "pecl download apcu" 5
    if [ -z "$2" ]; then
        echo 'missing argument for retry. usage: with_retry <command> <max-attempts>'
        exit $E_PARAM_ERR
    fi

    attempt=0
    until [ $attempt -ge $2 ]
    do
        $1 && break
        attempt=$[$attempt+1]
        echo "command '$1' failed"
        sleep $((2**$attempt))
    done
}

download_from_pecl()
{
    # Download the source code, rename, extract it for debian package
    # Usage:
    # download_from_pecl mailparse # for the latest
    # download_from_pecl mailparse 2.1.6 # for a specific version
    if [ -z "$1" ]; then
        echo 'missing argument for download_from_pecl'
        exit $E_PARAM_ERR
    fi
    PECL_PACKAGE_NAME=$1

    # chop off optional -beta from the package name. it is needed to specify
    # we are downloading a beta version, but is not actually part of the
    # package name
    PACKAGE_SHORT_NAME=$(basename ${PECL_PACKAGE_NAME} -beta)
    PACKAGE_SHORT_NAME=$(basename ${PACKAGE_SHORT_NAME} -alpha)
    PACKAGE_SHORT_NAME=$(basename ${PACKAGE_SHORT_NAME} -devel)

    if [ -z "$2" ]; then
        with_retry "pecl download ${PECL_PACKAGE_NAME}" 6
        # determine the downloaded version
        EXT_VERSION=$(ls ${PACKAGE_SHORT_NAME}-*.tgz | \
                sed "s/${PACKAGE_SHORT_NAME}-\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)\.tgz/\1/")
    else
        with_retry "pecl download ${PECL_PACKAGE_NAME}-${2}" 6
        EXT_VERSION="${2}"
    fi

    PACKAGE_VERSION="${EXT_VERSION}-${PHP_VERSION}"
    PACKAGE_FULL_VERSION="${EXT_VERSION}-${FULL_VERSION}"
    PACKAGE_DIR=${PNAME}-${PACKAGE_VERSION}
    mv ${PACKAGE_SHORT_NAME}-${EXT_VERSION}.tgz \
       ${PNAME}-${PACKAGE_VERSION}.orig.tar.gz
    mkdir -p ${PACKAGE_DIR}
    tar zxf ${PNAME}-${PACKAGE_VERSION}.orig.tar.gz \
        -C ${PACKAGE_DIR} --strip-components=1
}

download_from_tarball()
{
    # Download the source code, rename, extract it for debian package
    # Usage:
    # download_from_tarball https://github.com/phalcon/cphalcon/archive/v3.0.4.tar.gz 3.0.4
    if [ -z "$1" ]; then
        echo 'missing argument for download_from_tarball'
        exit $E_PARAM_ERR
    fi
    if [ -z "$2" ]; then
        echo 'missing argument for download_from_tarball'
        exit $E_PARAM_ERR
    fi

    EXT_VERSION=$2
    PACKAGE_VERSION="${EXT_VERSION}-${PHP_VERSION}"
    PACKAGE_FULL_VERSION="${EXT_VERSION}-${FULL_VERSION}"
    PACKAGE_DIR=${PNAME}-${PACKAGE_VERSION}

    # Download the file
    with_retry "curl -L $1 -o ${PNAME}-${PACKAGE_VERSION}.orig.tar.gz" 6
    mkdir -p ${PACKAGE_DIR}
    tar zxf ${PNAME}-${PACKAGE_VERSION}.orig.tar.gz \
        -C ${PACKAGE_DIR} --strip-components=1
}

install_last_package()
{
    if [ -z "$1" ]; then
        echo "missing argument for install_last_package"
        exit $E_PARAM_ERR
    fi
    ls -t ${ARTIFACT_DIR}/**/$1_* | head -n 1 | xargs dpkg -i
}

build_package()
{
    OUTPUT_FILE=${PNAME}_${EXT_VERSION}-${FULL_VERSION}_amd64.deb

    if [ ! -f "${ARTIFACT_PKG_DIR}/${OUTPUT_FILE}" ]; then
        cp -R ${DEB_BUILDER_DIR}/extensions/${1}/debian ${PACKAGE_DIR}

        if [ -e "${PACKAGE_DIR}/debian/rules.in" ]; then
            envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/rules.in \
                     > ${PACKAGE_DIR}/debian/rules
        fi
        chmod +x ${PACKAGE_DIR}/debian/rules
        if [ -e "${PACKAGE_DIR}/debian/control.in" ]; then
            envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/control.in \
                     > ${PACKAGE_DIR}/debian/control
        fi

        if [ -e "${PACKAGE_DIR}/debian/gcp-php-${1}.install.in" ]; then
            envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/gcp-php-${1}.install.in \
                     > ${PACKAGE_DIR}/debian/gcp-php${SHORT_VERSION}-${1}.install
        fi
        rm ${PACKAGE_DIR}/debian/*.in || true
        pushd ${PACKAGE_DIR}
        dch --create -v "${EXT_VERSION}-${FULL_VERSION}" \
            --package ${PNAME} --empty -M \
            "Build ${EXT_VERSION}-${FULL_VERSION} of ${PNAME}"
        dpkg-buildpackage -us -uc -j"$(nproc)"
        cp ../${OUTPUT_FILE} ${ARTIFACT_PKG_DIR}
        popd
    fi
}
