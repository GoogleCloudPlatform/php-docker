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
namespace Google\Cloud\tests;

require_once __DIR__ . '/Extensions.php';

use GuzzleHttp\Client;

class PHP5ExtensionsTest extends \PHPUnit_Framework_TestCase
{
    private $client;

    public static function setUpBeforeClass()
    {
        exec('docker run -d --name php56_custom -p 127.0.0.1:65080:8080 '
             . 'php56_custom');
        // Wait for nginx to start
        sleep(3);
    }

    public static function tearDownAfterClass()
    {
        exec('docker kill php56_custom');
        exec('docker rm php56_custom');
    }

    public function setUp()
    {
        $this->client = new Client(['base_uri' => 'http://localhost:65080/']);
    }

    public function testExtensions()
    {
        $expectedExtensions = array_merge(
            Extensions::$commonExtensions,
            array(
                # Both are gone with PHP 7.
                'ereg',
                'mysql',
                # Only available for PHP < 7 right now.
                'suhosin',
            )
        );
        $resp = $this->client->get('extensions.php');
        $loaded = $resp->getBody()->getContents();
        foreach ($expectedExtensions as $ext) {
            $this->assertContains($ext, $loaded);
        }
    }
}
