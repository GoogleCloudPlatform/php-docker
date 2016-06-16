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

class VersionTest extends \PHPUnit_Framework_TestCase
{
    public function setUp()
    {
    }

    public function testPHP56Version()
    {
        $checked = false;
        exec('docker run php56 /opt/php/bin/php -v', $output);
        foreach ($output as $k => $v) {
            if (strpos($v, 'PHP') === 0) {
                $this->assertContains('PHP 5.6', $v);
                $checked = true;
            }
        }
        $this->assertTrue($checked, 'Failed to check the version is 5.6.x');
    }
    public function testPHP70Version()
    {
        $checked = false;
        exec('docker run php70 /opt/php/bin/php -v', $output);
        foreach ($output as $k => $v) {
            if (strpos($v, 'PHP') === 0) {
                $this->assertContains('PHP 7.0', $v);
                $checked = true;
            }
        }
        $this->assertTrue($checked, 'Failed to check the version is 7.0.x');
    }
    public function testDefaultIsPHP56()
    {
        $checked = false;
        exec('docker run php56_70 /opt/php/bin/php -v', $output);
        foreach ($output as $k => $v) {
            if (strpos($v, 'PHP') === 0) {
                $this->assertContains('PHP 5.6', $v);
                $checked = true;
            }
        }
        $this->assertTrue($checked, 'Failed to check the version is 5.6.x');
    }
    public function testPhpInPath()
    {
        exec('docker run php56_70 env | grep "^PATH="', $output);
        $grep = array_pop($output);
        $paths = explode(':', str_replace('PATH=', '', $grep));
        $this->assertContains('/opt/php/bin', $paths);
    }
}
