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

class PostDeployCmdTest extends \PHPUnit_Framework_TestCase
{
    public function setUp()
    {
    }

    public function testInteractiveOutput()
    {
        exec('docker run php56_custom cat callable_output.txt', $output, $return_var);

        $this->assertEquals(0, $return_var);
        $this->assertEquals(1, count($output));
        $this->assertEquals('The script is not interactive!', $output[0]);
    }

    public function testPhpCliIni()
    {
        exec('docker run php56_custom cat cli-ini-test.txt', $output, $return_var);

        $this->assertEquals(0, $return_var);
        $this->assertEquals(1, count($output));
        $this->assertEquals('shell_exec succeeded', $output[0]);
    }

    public function testCommandOutput()
    {
        exec('docker run php56_custom cat script_output.txt', $output, $return_var);

        $this->assertEquals(0, $return_var);
        $this->assertEquals(1, count($output));
        $this->assertEquals('Testing Post Deploy Command', $output[0]);
    }

    public function testFilePermissions()
    {
        exec('docker run php56_custom stat -c "%a %n" script_output.txt', $output, $return_var);

        $this->assertEquals(0, $return_var);
        $this->assertEquals(1, count($output));
        $this->assertEquals('777 script_output.txt', $output[0]);
    }
}
