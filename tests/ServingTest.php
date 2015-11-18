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

class ServingTest extends \PHPUnit_Framework_TestCase
{
    private $pid;
    private $client;

    public function setUp()
    {
        exec('docker run -d --name php56 -p 127.0.0.1:8080:8080 php56');
        // Wait for nginx to start
        sleep(3);
        $this->client = new Client(['base_uri' => 'http://localhost:8080/']);
    }

    public function tearDown()
    {
        exec('docker kill php56');
        exec('docker rm php56');
    }

    public function testPages()
    {
        // Index serves succesfully with 'Hello World'.
        $resp = $this->client->get('index.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'index.php status code');
        $this->assertContains('Hello World', $resp->getBody()->getContents());

        // Access to phpinfo.php, while phpinfo() is disabled by default.
        $resp = $this->client->get('phpinfo.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'phpinfo.php status code');
        $this->assertEquals('', $resp->getBody()->getContents(),
                            'phpinfo() should be disabled and the content'
                            . ' should be empty.');

        // Access to pdo_sqlite.php, while the extention is not available.
        try {
            $resp = $this->client->get('pdo_sqlite.php');
        } catch (\GuzzleHttp\Exception\ServerException $e) {
            $this->assertEquals('500', $e->getResponse()->getStatusCode(),
                                'pdo_sqlite.php status code');

            return;
        }
        $this->fail('Access to pdo_sqlite.php should error with status 500.');
    }
}
