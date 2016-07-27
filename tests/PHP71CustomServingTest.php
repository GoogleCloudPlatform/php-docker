<?php

/**
 * Copyright 2015 Google Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
namespace Google\Cloud\tests;

use GuzzleHttp\Client;

class PHP71CustomServingTest extends \PHPUnit_Framework_TestCase
{
    private $client;

    public static function setUpBeforeClass()
    {
        exec(
            'docker run -d --name php71_custom -p 127.0.0.1:65080:8080 '
            . 'php71_custom'
        );
        // Wait for nginx to start
        sleep(3);
    }

    public static function tearDownAfterClass()
    {
        exec(
            'docker exec -t php71_custom find /var/log/app_engine '
            . '-type f -exec tail {} \;',
            $output
        );
        var_dump($output);
        exec('docker kill php71_custom');
        exec('docker rm php71_custom');
    }

    public function setUp()
    {
        $this->client = new Client(['base_uri' => 'http://localhost:65080/']);
    }

    public function testParseStrIsSafe()
    {
        // Access to parse_str.php and make sure it doesn't override global
        // variables.
        $resp = $this->client->get('parse_str.php');
        $this->assertEquals(
            '200',
            $resp->getStatusCode(),
            'parse_str.php status code'
        );
        $this->assertContains(
            'This is an important variable',
            $resp->getBody()->getContents()
        );
    }

    public function testVersion71IsPresent()
    {
        $response = $this->client->get('version.php');

        $this->assertContains('7.1', $response->getContents(), 'The PHP 7.1 version string should be visible');
    }
}
