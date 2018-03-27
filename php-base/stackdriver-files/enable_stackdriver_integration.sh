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


# A shell script for enabling stackdriver integration

if [ "${BUILDER_DEBUG_OUTPUT}" = "true" ]; then
    set -xe
else
    set -e
fi

echo "Enabling stackdriver integration..."

# To start the batch daemon
cp /stackdriver-files/batch-daemon.conf /etc/supervisor/conf.d

# Detect the stackdriver prepend path
set +e
PREPEND_PATH=`php /stackdriver-files/locate_stackdriver_prepend.php`
set -e
if [ $? -ne 0 ]; then
    if [ "${1}" = "--individual" ]; then
        PREPEND_PATH="/app/vendor/google/cloud-error-reporting/prepend.php"
    else
        PREPEND_PATH="/app/vendor/google/cloud/src/ErrorReporting/prepend.php"
    fi
fi
echo "auto_prepend_file=$PREPEND_PATH" > ${PHP_DIR}/lib/conf.d/stackdriver-prepend.ini
