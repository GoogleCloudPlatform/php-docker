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

class PHP56Test extends \PHPUnit_Framework_TestCase
{
    private $client;

    public static function setUpBeforeClass()
    {
        sleep(3);
    }

    public function setUp()
    {
        $this->client = new Client(['base_uri' => 'http://php56:8080/']);
    }

    public function testIndex()
    {
        // Index serves succesfully with 'Hello World'.
        $resp = $this->client->get('index.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'index.php status code');
        $this->assertContains('Hello World', $resp->getBody()->getContents());
    }

    public function testNonExistentPath()
    {
        // Non-existent paths should be served by the `index.php` too, thanks
        // to the default nginx-app.conf.
        $resp = $this->client->get('non-existent-path');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'non-existent-path status code');
        $this->assertContains('Hello World', $resp->getBody()->getContents());
    }

    public function testPhpInfo()
    {
        // Access to phpinfo.php, while phpinfo() should be enabled by default.
        $resp = $this->client->get('phpinfo.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'phpinfo.php status code');
        $this->assertTrue(strlen($resp->getBody()->getContents()) > 1000,
                          'phpinfo() should be enabled.');
    }

    public function testPdoSqlite()
    {
        // Access to pdo_sqlite.php, while the extention is not available.
        // ServerException is thrown when the server returns 500 status code.
        $this->setExpectedException('\GuzzleHttp\Exception\ServerException');
        $resp = $this->client->get('pdo_sqlite.php');
    }
}
