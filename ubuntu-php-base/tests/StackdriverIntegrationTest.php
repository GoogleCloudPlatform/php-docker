<?php
/**
 * Copyright 2018 Google Inc.
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

use PHPUnit\Framework\TestCase;

class StackdriverIntegrationTest extends TestCase
{
    private $oldpwd;

    public function setUp()
    {
        parent::setUp();
        $this->oldpwd = getcwd();
    }

    public function tearDown()
    {
        chdir($this->oldpwd);
        parent::tearDown();
    }

    /**
     * @dataProvider validVersions
     */
    public function testValidVersions($directory, $expectedFile)
    {
        $dir = realpath(__DIR__ . '/' . $directory);
        exec("cd $dir && composer install --ignore-platform-reqs -q 2>&1", $output, $retVal);
        $this->assertEquals(0, $retVal, 'command failed with: ' . implode(';', $output));

        exec("php stackdriver-files/enable_stackdriver_prepend.php -a $dir", $output, $retVal);
        $this->assertEquals(0, $retVal, 'command failed with: ' . implode(';', $output));
        $output = trim(array_pop($output));
        $this->assertStringStartsWith('auto_prepend_file=', $output);
        $this->assertStringEndsWith($expectedFile, $output);
    }

    public function validVersions()
    {
        return [
            ['samples/stackdriver_individual', 'vendor/google/cloud-error-reporting/prepend.php'],
            ['samples/stackdriver_simple', 'vendor/google/cloud/src/ErrorReporting/prepend.php'],
            ['samples/stackdriver_wildcard', 'vendor/google/cloud/ErrorReporting/src/prepend.php'],
            ['samples/stackdriver_dev', 'vendor/google/cloud/ErrorReporting/src/prepend.php'],
        ];
    }

    /**
     * @dataProvider invalidVersions
     */
    public function testInvalidVersions($directory)
    {
        $dir = realpath(__DIR__ . '/' . $directory);
        exec("cd $dir && composer install --ignore-platform-reqs -q 2>&1", $output, $retVal);
        $this->assertEquals(0, $retVal, 'command failed with: ' . implode(';', $output));

        exec("php stackdriver-files/enable_stackdriver_prepend.php -a $dir", $output, $retVal);
        $this->assertNotEquals(0, $retVal, 'command: ' . implode(';', $output) . ' should have failed.');
        $this->assertContains('You must include', $output[0]);
    }

    public function invalidVersions()
    {
        return [
            ['samples/stackdriver_no_google_cloud'],
            ['samples/stackdriver_old_er'],
            ['samples/stackdriver_old_google_cloud'],
            ['samples/stackdriver_old_logging']
        ];
    }

    public function testNoComposer()
    {
        $dir = realpath(__DIR__ . '/samples/no_composer');
        exec("php stackdriver-files/enable_stackdriver_prepend.php -a $dir", $output, $retVal);
        $this->assertNotEquals(0, $retVal, 'command: ' . implode(';', $output) . ' should have failed.');
        $this->assertContains('You must include', $output[0]);
    }
}
