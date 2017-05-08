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

class PHP56NginxConfTest extends \PHPUnit_Framework_TestCase
{
    private $client;

    public static function setUpBeforeClass()
    {
        sleep(3);
    }

    public function setUp()
    {
        $this->client = new Client(['base_uri' => 'http://php56-nginx-conf:8080/']);
    }

    public function testHello()
    {
        // hello serves succesfully with 'hello from nginx.conf'.
        $resp = $this->client->get('hello');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'hello status code');
        $this->assertContains(
            'hello from nginx.conf',
            $resp->getBody()->getContents()
        );
    }
}
