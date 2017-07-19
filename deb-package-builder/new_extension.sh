#!/bin/bash
# Copyright 2017 Google Inc.
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

set -ex

export EXT_FULL_NAME=$1
export EXT_NAME=${EXT_FULL_NAME//_/-}
export UPSTREAM_NAME=$2
export HOMEPAGE=$3
export MAINTAINER=$4

echo "building ${EXT_NAME}"

if [ -d "extensions/${EXT_FULL_NAME}" ]
then
    echo "extension folder already exists"
    exit 1
fi

mkdir -p extensions/${EXT_FULL_NAME}/debian

cp extensions/skeleton/debian/compat extensions/${EXT_FULL_NAME}/debian/compat
envsubst '${EXT_NAME} ${MAINTAINER} ${HOMEPAGE}' < extensions/skeleton/debian/control.in > extensions/${EXT_FULL_NAME}/debian/control.in
envsubst '${EXT_NAME} ${UPSTREAM_NAME} ${HOMEPAGE}' < extensions/skeleton/debian/copyright > extensions/${EXT_FULL_NAME}/debian/copyright
envsubst '${EXT_NAME}' < extensions/skeleton/debian/ext.ini > extensions/${EXT_FULL_NAME}/debian/ext-${EXT_NAME}.ini
envsubst '${EXT_NAME}' < extensions/skeleton/debian/install.in > extensions/${EXT_FULL_NAME}/debian/gcp-php-${EXT_NAME}.install.in
envsubst '${EXT_NAME}' < extensions/skeleton/debian/rules.in > extensions/${EXT_FULL_NAME}/debian/rules.in
envsubst '${EXT_NAME} ${EXT_FULL_NAME}' < extensions/skeleton/build.sh > extensions/${EXT_FULL_NAME}/build.sh

chmod +x extensions/${EXT_FULL_NAME}/build.sh
