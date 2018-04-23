<?php
/**
 * Copyright 2017 Google Inc.
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

require_once __DIR__ . '/src/InstallExtensions.php';

if (basename($argv[0]) == basename(__FILE__)) {
    if (count($argv) < 2) {
        die("Usage:\n" . $argv[0] . " filename\n");
    }

    $outputFile = count($argv) > 2 ? $argv[2] : null;
    $phpVersion = count($argv) > 3 ? $argv[3] : null;

    $installer = new InstallExtensions($argv[1], $outputFile, $phpVersion);
    if (!$installer->installExtensions()) {
        echo "Failed to install all requested extensions:\n";
        foreach ($installer->errors() as $message) {
            echo $message . PHP_EOL;
        }
        exit(1);
    }
}
