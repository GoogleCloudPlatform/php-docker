<?php
/**
 * Copyright 2016 Google Inc.
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
    }

    public function setUp()
    {
        $this->client = new Client(['base_uri' => 'http://php56-custom-configs:8080/']);
    }

    public function testHello()
    {
        // hello serves succesfully with 'hello from nginx-custom.conf'.
        $resp = $this->client->get('hello');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'hello status code');
        $this->assertContains(
            'hello from nginx-custom.conf',
            $resp->getBody()->getContents()
        );
    }

    public function testNginxUserConf()
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

    public function testNginxCustomConf()
    {
        $resp = $this->client->get(
            'readfile.php?f=' . urlencode('/etc/nginx/nginx.conf')
        );
        $this->assertEquals(
            '200',
            $resp->getStatusCode(),
            'readfile status code'
        );
        $this->assertContains(
            'nginx-custom.conf',
            $resp->getBody()->getContents()
        );
    }

    public function testPhpFpmUserConf()
    {
        $resp = $this->client->get(
            'readfile.php?f=' . urlencode('/opt/php/etc/php-fpm-user.conf')
        );
        $this->assertEquals(
            '200',
            $resp->getStatusCode(),
            'readfile status code'
        );
        $this->assertContains(
            'php-fpm-user.conf',
            $resp->getBody()->getContents()
        );
    }

    public function testPhpIni()
    {
        $resp = $this->client->get(
            'readfile.php?f=' . urlencode('/opt/php/lib/conf.d/php-user.ini')
        );
        $this->assertEquals(
            '200',
            $resp->getStatusCode(),
            'readfile status code'
        );
        $this->assertContains(
            'php-user.ini',
            $resp->getBody()->getContents()
        );
    }

    public function testMySupervisordConf()
    {
        $resp = $this->client->get(
            'readfile.php?f='
            . urlencode('/etc/supervisor/conf.d/my-supervisord.conf')
        );
        $this->assertEquals(
            '200',
            $resp->getStatusCode(),
            'readfile status code'
        );
        $this->assertContains(
            'my-supervisord.conf',
            $resp->getBody()->getContents()
        );
    }

    public function testCustomSupervisordConf()
    {
        $resp = $this->client->get(
            'readfile.php?f='
            . urlencode('/etc/supervisor/supervisord.conf')
        );
        $this->assertEquals(
            '200',
            $resp->getStatusCode(),
            'readfile status code'
        );
        $this->assertContains(
            'custom-supervisord.conf',
            $resp->getBody()->getContents()
        );
    }
}
