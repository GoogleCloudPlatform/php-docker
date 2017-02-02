<?php
/**
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
require_once __DIR__ . '/vendor/autoload.php';

use Composer\Semver\Semver;

// Available versions in the order we want to check.
$available_versions = [
    getenv('PHP71_VERSION'),
    getenv('PHP70_VERSION'),
    getenv('PHP56_VERSION'),
];

if (count($argv) < 2) {
    die("Usage:\n" . $argv[0] . " filename\n");
}

$composer = json_decode(file_get_contents($argv[1]), true);

$php_version = '';

if (is_array($composer)
    && array_key_exists('require', $composer)
    && array_key_exists('php', $composer['require'])) {
    $constraints = $composer['require']['php'];
    foreach ($available_versions as $version) {
        if (Semver::satisfies($version, $constraints)) {
            // The first match wins, picking the highest version possible.
            $php_version = substr($version, 0, strrpos($version, '.'));
            break;
        }
    }
}

echo $php_version;
