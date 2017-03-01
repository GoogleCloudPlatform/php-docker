<?php

/*
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

// [START index_php]
require_once __DIR__ . '/../vendor/autoload.php';

use Google\Cloud\Logging\LoggingClient;
use Symfony\Component\HttpFoundation\Request;

$app = new Silex\Application();

$app->get('/', function () {
    return 'Hello World!';
});

$app->post('/logging', function (Request $request) {
    $logName = $request->get('log_name');
    $token = $request->get('token');

    $logging = new LoggingClient();
    $logger = $logging->logger($logName);
    $logger->write($token);

    return 'OK';
});

// This test does not work yet. The monitoring client is NYI.
$app->post('/monitoring', function () {
    return 'NYI';
});

// This test does not work yet. The exception reporting client is NYI.
$app->post('/exception', function () {
    return 'NYI';
});

// @codeCoverageIgnoreStart
if (PHP_SAPI != 'cli') {
    $app->run();
}
// @codeCoverageIgnoreEnd

return $app;
// [END index_php]
