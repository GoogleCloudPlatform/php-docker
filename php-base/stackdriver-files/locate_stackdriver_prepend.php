<?php
/**
 * Copyright 2018 Google Inc.
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

$appDir = getenv('APP_DIR');
$appDir = $appDir ?: '/app';

// Use the application's vendor/autoload.php
require_once $appDir . '/vendor/autoload.php';

use Google\Cloud\ErrorReporting\Bootstrap;

if (class_exists(Bootstrap::class)) {
    $reflection = new \ReflectionClass(Bootstrap::class);
    if ($reflection->hasMethod('prependFileLocation')) {
        echo Bootstrap::prependFileLocation() . PHP_EOL;
    } else {
        // default to same directory as the Bootstrap.php
        echo realpath(dirname($reflection->getFileName()) . '/prepend.php') . PHP_EOL;
    }
} else {
    die('cannot find ErrorReporting\Bootstrap class');
}
