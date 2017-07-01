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

$app->post('/logging_standard', function (Request $request) {
    $token = $request->request->get('token');
    $stderr = fopen('php://stderr', 'w');
    fwrite($stderr, $token . PHP_EOL);
    fclose($stderr);

    return 'appengine.googleapis.com%2Fstderr';
});

$app->post('/logging_custom', function (Request $request) {
    $logName = $request->request->get('log_name');
    $token = $request->request->get('token');
    $level = $request->request->get('level');

    $logger = LoggingClient::psrBatchLogger($logName);
    $logger->log($level, $token);

    return $logName;
});

// This test does not work yet. The monitoring client is NYI.
$app->post('/monitoring', function () {
    return 'NYI';
});

// This test does not work yet. The exception reporting client is NYI.
$app->post('/exception', function () {
    return 'NYI';
});

$app->get('/custom', function () {
    // No custom tests, so just return OK.
    return 'OK';
});

$app['debug'] = true;

$app->before(function (Request $request) {
    if (0 === strpos($request->headers->get('Content-Type'), 'application/json')) {
        $data = json_decode($request->getContent(), true);
        $request->request->replace(is_array($data) ? $data : array());
    }
});

// @codeCoverageIgnoreStart
if (PHP_SAPI != 'cli') {
    $app->run();
}
// @codeCoverageIgnoreEnd

return $app;
// [END index_php]
