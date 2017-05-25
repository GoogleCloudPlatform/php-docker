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


# A shell script for dumping php versions to files.
set -xe

PHP_SHORT_NAMES=(php56 php70 php71)

for PHP_SHORT_NAME in "${PHP_SHORT_NAMES[@]}"
do
    apt-cache show gcp-${PHP_SHORT_NAME}|grep Version \
        |grep  -o -P "(\\d+\\.\\d+\\.\\d+)" > "/opt/${PHP_SHORT_NAME}_version"
done
