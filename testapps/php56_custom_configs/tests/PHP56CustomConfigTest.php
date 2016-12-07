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

use GuzzleHttp\Client;

class PHP56CustomConfigTest extends \PHPUnit_Framework_TestCase
{
    private $client;

    public static function setUpBeforeClass()
    {
        // Wait for nginx to start
        sleep(3);
        // For a test for long running requests
        ini_set("default_socket_timeout", 70);
    }

    public function setUp()
    {
        $this->client = new Client(['base_uri' => 'http://test-app:8080/']);
    }

    public function testIndex()
    {
        $resp = $this->client->get(
            'readfile.php?f=' . urlencode('/etc/nginx/conf.d/nginx-user.conf')
        );
        $this->assertEquals(
            '200',
            $resp->getStatusCode(),
            'readfile status code'
        );
        $this->assertContains(
            'nginx-user.conf',
            $resp->getBody()->getContents()
        );
    }
}
