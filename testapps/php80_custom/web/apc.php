<?php

/*
 * Copyright 2015 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
$value = 'STRINGTOBECACHED';

if (true === apc_store('artificialkey', $value)) {
    echo('success storing in apc bc' . PHP_EOL);
}

if ($value === apc_fetch('artificialkey')) {
    echo('success fetching from apc bc' . PHP_EOL);
}

if (true === apc_delete('artificialkey')) {
    echo('success deleting from apc bc' . PHP_EOL);
}

if (true === apcu_add('artificialkey', $value)) {
    echo('success storing in apcu' . PHP_EOL);
}

if ($value === apcu_fetch('artificialkey')) {
    echo('success fetching from apcu' . PHP_EOL);
}

if (true === apcu_delete('artificialkey')) {
    echo('success deleting from apcu' . PHP_EOL);
}
