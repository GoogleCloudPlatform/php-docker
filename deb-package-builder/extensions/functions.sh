#!/bin/bash

# common functions for building extensions

E_PARAM_ERR=250

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
    if [ -z "$2" ]; then
        pecl download "${1}"
        # determine the downloaded version
        EXT_VERSION=$(ls ${1}-*.tgz | \
                sed "s/${1}-\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)\.tgz/\1/")
    else
        pecl download "${1}-${2}"
        EXT_VERSION="${2}"
    fi
    PACKAGE_VERSION="${EXT_VERSION}-${PHP_VERSION}"
    PACKAGE_FULL_VERSION="${EXT_VERSION}-${FULL_VERSION}"
    PACKAGE_DIR=${PNAME}-${PACKAGE_VERSION}
    mv ${1}-${EXT_VERSION}.tgz \
       ${PNAME}-${PACKAGE_VERSION}.orig.tar.gz
    mkdir -p ${PACKAGE_DIR}
    tar zxvf ${PNAME}-${PACKAGE_VERSION}.orig.tar.gz \
        -C ${PACKAGE_DIR} --strip-components=1
}
