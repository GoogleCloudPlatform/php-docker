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


# A shell script for installing PHP depending on the PHP_VERSION environment variable
set -xe

echo "PHP_VERSION is $PHP_VERSION"

case $PHP_VERSION in
    7.4*)
        /bin/bash /build-scripts/install_php74.sh
        ;;
    7.3*)
        /bin/bash /build-scripts/install_php73.sh
        ;;
    7.2*)
        /bin/bash /build-scripts/install_php72.sh
        ;;
    *)
        /bin/bash /build-scripts/install_php71.sh
        ;;
esac
