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
ENV APP_NGINX_ADDITIONAL_CONF=nginx-user.conf \
    APP_NGINX_CONF=nginx-custom.conf \
    APP_PHP_FPM_CONF=php-fpm-user.conf \
    APP_PHP_INI=php-user.ini \
    APP_SUPERVISORD_CONF=app-supervisord.conf
