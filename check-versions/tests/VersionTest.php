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
use PHPUnit\Framework\TestCase;

class VersionTest extends TestCase
{
    private static $versions;

    public static function setUpBeforeClass()
    {
        self::$versions = array();
        $client = new Client(['base_uri' => 'http://www.php.net']);
        $response = $client->request('GET', '/downloads.php');
        $body = $response->getBody();

        $pattern = '/PHP (7\.1\.\d+)/';
        if (preg_match($pattern, $body, $matches)) {
            self::$versions['php71'] = $matches[1];
        } else {
            self::$versions['php71'] =
                'Failed to detect the latest PHP71 version';
        }

        $pattern = '/PHP (7\.3\.\d+)/';
        if (preg_match($pattern, $body, $matches)) {
            self::$versions['php73'] = $matches[1];
        } else {
            self::$versions['php73'] =
                'Failed to detect the latest PHP73 version';
        }

        $pattern = '/PHP (7\.4\.\d+)/';
        if (preg_match($pattern, $body, $matches)) {
            self::$versions['php74'] = $matches[1];
        } else {
            self::$versions['php74'] =
                'Failed to detect the latest PHP74 version';
        }

        exec('apt-get update');
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

    public function testPHP73Version()
    {
        $output = exec('apt-cache madison gcp-php73');
        $pattern = '/(7\.3\.\d+)/';
        if (preg_match($pattern, $output, $matches)) {
            $this->assertEquals($matches[1], self::$versions['php73']);
        } else {
            $this->fail('Failed to detect the current php73 version');
        }
    }

    public function testPHP74Version()
    {
        $output = exec('apt-cache madison gcp-php74');
        $pattern = '/(7\.4\.\d+)/';
        if (preg_match($pattern, $output, $matches)) {
            $this->assertEquals($matches[1], self::$versions['php74']);
        } else {
            $this->fail('Failed to detect the current php74 version');
        }
    }
}
