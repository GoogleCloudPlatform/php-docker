<?php
/**
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

use GuzzleHttp\Client;

class VersionTest extends \PHPUnit_Framework_TestCase
{
    private static $versions;

    public static function setUpBeforeClass()
    {
        self::$versions = array();
        $client = new Client(['base_uri' => 'http://www.php.net']);
        $response = $client->request('GET', '/downloads.php');
        $body = $response->getBody();

        $pattern = '/PHP (5\.6\.\d+)/';
        if (preg_match($pattern, $body, $matches)) {
            self::$versions['php56'] = $matches[1];
        } else {
            self::$versions['php56'] =
                'Failed to detect the latest PHP56 version';
        }

        $pattern = '/PHP (7\.0\.\d+)/';
        if (preg_match($pattern, $body, $matches)) {
            self::$versions['php70'] = $matches[1];
        } else {
            self::$versions['php70'] =
                'Failed to detect the latest PHP70 version';
        }

        $pattern = '/PHP (7\.1\.\d+)/';
        if (preg_match($pattern, $body, $matches)) {
            self::$versions['php71'] = $matches[1];
        } else {
            self::$versions['php71'] =
                'Failed to detect the latest PHP70 version';
        }

        exec('apt-get update');
    }

    public function testPHP56Version()
    {
        $output = exec('apt-cache madison gcp-php56');
        $pattern = '/(5\.6\.\d+)/';
        if (preg_match($pattern, $output, $matches)) {
            $this->assertEquals($matches[1], self::$versions['php56']);
        } else {
            $this->fail('Failed to detect the current php56 version');
        }
    }

    public function testPHP70Version()
    {
        $output = exec('apt-cache madison gcp-php70');
        $pattern = '/(7\.0\.\d+)/';
        if (preg_match($pattern, $output, $matches)) {
            $this->assertEquals($matches[1], self::$versions['php70']);
        } else {
            $this->fail('Failed to detect the current php70 version');
        }
    }

    public function testPHP71Version()
    {
        $output = exec('apt-cache madison gcp-php71');
        $pattern = '/(7\.1\.\d+)/';
        if (preg_match($pattern, $output, $matches)) {
            $this->assertEquals($matches[1], self::$versions['php71']);
        } else {
            $this->fail('Failed to detect the current php71 version');
        }
    }
}
