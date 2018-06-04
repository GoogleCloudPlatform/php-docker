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

$options = getopt('a:o:') + [
    'a' => '/app',
    'o' => 'php://stdout'
];

$autoload = $options['a'] . '/vendor/autoload.php';
if (file_exists($autoload)) {
    require_once $autoload;
}
require_once __DIR__ . '/stackdriver_integration.php';

$integration = new StackdriverIntegration();

try {
    $location = $integration->prependFileLocation();
    $fp = fopen($options['o'], 'w');
    if ($fp === false) {
        throw new RuntimeException(sprintf('Failed opening file %s for writing.', $options['o']));
    }
    try {
        $ret = fwrite($fp, 'auto_prepend_file=' . $location . PHP_EOL);
        if ($ret === false) {
            throw new RuntimeException(sprintf('Failed writing to file: %s', $options['o']));
        }
    } finally {
        fclose($fp);
    }
} catch (Exception $e) {
    echo $e->getMessage();
    exit(1);
}
