#!/bin/bash

# Copyright 2015 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# A shell script for installing build tools and deps for building
# nginx and PHP.

set -xe

# Tools needed for building from source.
BUILD_TOOLS=" \
    autoconf \
    bison \
    file \
    g++ \
    gcc \
    libc-dev \
    make \
    patch \
    pkg-config \
    re2c \
    binutils \
  "

# Headers files etc for libraries we build against
BUILD_DEPS=" \
    libbz2-dev \
    libcurl4-openssl-dev \
    libgettextpo-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libmemcached-dev \
    libpcre3-dev \
    libpng-dev \
    libpq-dev \
    libreadline6-dev \
    librecode-dev \
    libsasl2-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
  "

function install_apt_deps {
    apt-get update
    apt-get install -y $BUILD_TOOLS $BUILD_DEPS --no-install-recommends
}

function uninstall_apt_deps {
    apt-get purge -y --auto-remove -o \
        APT::AutoRemove::RecommendsImportant=false -o \
        APT::AutoRemove::SuggestsImportant=false $BUILD_TOOLS $BUILD_DEPS
    rm -rf /var/lib/apt/lists/*
}

if [ $1 == 'install' ]; then

    install_apt_deps

elif [ $1 == 'uninstall' ]; then

    uninstall_apt_deps

fi
