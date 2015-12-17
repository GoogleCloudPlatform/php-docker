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


# A shell script for importing php keys
set -xe

NGINX_GPG_KEYS=" \
    F5806B4D \
    A524C53E \
    A1C052F8 \
    2C172083 \
    7ADB39A8 \
    6C7E5E82 \
    7BD9BF62"

gpg --keyserver pgp.mit.edu --recv-keys $NGINX_GPG_KEYS

PHP_GPG_KEYS=" \
    0BD78B5F97500D450838F95DFE857D9A90D90EC1 \
    6E4F6AB321FDC07F2C332E3AC2BF0BC433CFC8B3 \
    1A4E8B7277C42E53DBA9C7B9BCAA30EA9C0D5763"

gpg --keyserver pgp.mit.edu --recv-keys $PHP_GPG_KEYS
