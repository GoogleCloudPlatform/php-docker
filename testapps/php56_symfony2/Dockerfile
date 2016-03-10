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

FROM php-nginx

ENV DOCUMENT_ROOT=/app/web
ENV SYMFONY_ENV prod

RUN cd $APP_DIR && $PHP_DIR/bin/php \
    -d suhosin.executor.include.whitelist=phar \
    -d suhosin.executor.func.blacklist=none \
    -d disable_functions= \
    -d memory_limit=-1 \
    -d max_input_time=-1 \
    /usr/local/bin/composer \
    install \
    --prefer-dist \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --no-ansi \
    --no-progress
