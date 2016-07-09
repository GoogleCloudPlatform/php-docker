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

class CustomServingTest extends \PHPUnit_Framework_TestCase
{
    private $client;

    public static function setUpBeforeClass()
    {
        exec('docker run -d --name php56_custom -p 127.0.0.1:65080:8080 '
             . 'php56_custom');
        // Wait for nginx to start
        sleep(3);
        // For a test for long running requests
        ini_set("default_socket_timeout", 70);
    }

    public static function tearDownAfterClass()
    {
        exec('docker exec -t php56_custom find /var/log/app_engine '
             . '-type f -exec tail {} \;', $output);
        var_dump($output);
        exec('docker kill php56_custom');
        exec('docker rm php56_custom');
    }

    public function setUp()
    {
        $this->client = new Client(['base_uri' => 'http://localhost:65080/']);
    }

    public function testIndex()
    {
        // Index serves succesfully with 'Hello World'.
        // This works because the custom DOCUMENT_ROOT is working.
        $resp = $this->client->get('index.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'index.php status code');
        $this->assertContains('Hello World', $resp->getBody()->getContents());
    }

    public function testGoodbye()
    {
        // The URL '/goodbye' works with 'Goodbye World'.
        // This works because the nginx-app.conf is effective.
        $resp = $this->client->get('/goodbye');
        $this->assertEquals('200', $resp->getStatusCode(),
                            '/goodbye status code');
        $this->assertContains('Goodbye World',
                              $resp->getBody()->getContents());
    }

    public function testPhpInfo()
    {
        // Access to phpinfo.php, while phpinfo() should be enabled this time.
        $resp = $this->client->get('phpinfo.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'phpinfo.php status code');
        $this->assertTrue(strlen($resp->getBody()->getContents()) > 1000,
                          'phpinfo() should be enabled.');
    }

    public function testExec()
    {
        // Access to exec.php; exec() should be enabled.
        $resp = $this->client->get('exec.php');
        $this->assertEquals(
            '200',
            $resp->getStatusCode(),
            'exec.php status code'
        );
        $this->assertContains(
            'exec succeeded.',
            $resp->getBody()->getContents()
        );
    }

    public function testPdoSqlite()
    {
        // Access to pdo_sqlite.php, which should work.
        $resp = $this->client->get('pdo_sqlite.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'pdo_sqlite.php status code');
        $this->assertContains('Hello pdo_sqlite',
                              $resp->getBody()->getContents());
    }

    public function testNumberOfPhpFpmChildren()
    {
        $resp = $this->client->get('php-fpm-count.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'php-fpm-count.php status code');
        $this->assertEquals(
            2,
            intval($resp->getBody()->getContents()),
            'There should be only 2 php-fpm processes, actual: '
            . $resp->getBody()->getContents()
        );
    }

    public function testNumberOfNginxChildren()
    {
        exec('nproc', $nproc);
        $resp = $this->client->get('nginx-count.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'nginx-count.php status code');
        $count = intval($resp->getBody()->getContents());
        $this->assertGreaterThan(
            $nproc[0], $count,
            "There should be more than $nproc[0] nginx processes, actual: $count"
        );
    }

    public function testParseStrIsSafe()
    {
        // Access to parse_str.php and make sure it doesn't override global
        // variables.
        $resp = $this->client->get('parse_str.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'parse_str.php status code');
        $this->assertContains('This is an important variable',
                              $resp->getBody()->getContents());
    }

    public function testSleep()
    {
        // Access to pdo_sqlite.php, which should work.
        $resp = $this->client->get('sleep');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'sleep status code');
        $this->assertContains('Slept 61 seconds',
                              $resp->getBody()->getContents());
    }
}
