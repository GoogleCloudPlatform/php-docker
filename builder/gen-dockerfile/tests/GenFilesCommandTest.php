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
namespace Google\Cloud\Runtimes\Builder;

use Symfony\Component\Console\Tester\CommandTester;

class GenFilesCommandTest extends \PHPUnit_Framework_TestCase
{
    public static $testDir;

    public static function setUpBeforeClass()
    {
        self::$testDir = tempnam(sys_get_temp_dir(), 'GenFilesTest');
        if (file_exists(self::$testDir)) {
            unlink(self::$testDir);
        }
        mkdir(self::$testDir);
    }

    public static function tearDownAfterClass()
    {
        rmdir(self::$testDir);
    }

    public function setUp()
    {
        // Set default envvar
        putenv('GAE_APPLICATION_YAML_PATH=app.yaml');
    }

    public function tearDown()
    {
        $files = array('app.yaml', 'my.yaml', 'Dockerfile', '.dockerignore');
        foreach ($files as $file) {
            if (file_exists(self::$testDir . '/' . $file)) {
                unlink(self::$testDir . '/' . $file);
            }
        }
    }

    /**
     * @dataProvider dataProvider
     */
    public function testGenFilesCommand(
        $dir,
        $baseImage,
        $appYamlEnv,
        $expectedDocRoot,
        $expectedDockerIgnore,
        $expectedFrom,
        $otherExpectations = []
    ) {
        // Copy all the files to the test dir
        $files = array('app.yaml', 'my.yaml', 'Dockerfile', '.dockerignore');
        foreach ($files as $file) {
            if (file_exists($dir . '/' . $file)) {
                copy($dir . '/' . $file, self::$testDir . '/' . $file);
            }
        }
        if (!empty($appYamlEnv)) {
            putenv('GAE_APPLICATION_YAML_PATH=' . $appYamlEnv);
        }
        $genFiles = new GenFilesCommand();
        $commandTester = new CommandTester($genFiles);
        $commandTester->execute([
            'base-image' => $baseImage,
            '--workspace' => self::$testDir
        ]);

        $dockerfile = file_get_contents(self::$testDir . '/Dockerfile');
        $this->assertTrue($dockerfile !== false, 'Dockerfile should exist');
        $this->assertContains(
            'DOCUMENT_ROOT=' . $expectedDocRoot,
            $dockerfile
        );
        $this->assertContains('FROM ' . $expectedFrom, $dockerfile);
        $genFiles->createDockerignore();
        $dockerignore = file_get_contents(self::$testDir . '/.dockerignore');
        $this->assertTrue(
            $dockerignore !== false,
            '.dockerignore should exist'
        );
        $this->assertContains(
            $expectedDockerIgnore,
            $dockerignore
        );
        if (!empty($appYamlEnv)) {
            $this->assertContains($appYamlEnv, $dockerignore);
        }
        foreach ($otherExpectations as $expectation) {
            $this->assertContains($expectation, $dockerfile);
        }
    }

    public function dataProvider()
    {
        return [
            [
                // Simplest case
                __DIR__ . '/test_data/simplest',
                '',
                '',
                '/app',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php-base:latest',
                ["GOOGLE_RUNTIME_RUN_COMPOSER_SCRIPT=true \n"]
            ],
            [
                // whitelist_functions
                __DIR__ . '/test_data/whitelist_functions',
                '',
                '',
                '/app',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php-base:latest',
                ["WHITELIST_FUNCTIONS=exec \\\n"]
            ],
            [
                // whitelist_functions on env_variables
                __DIR__ . '/test_data/whitelist_functions_on_env',
                '',
                '',
                '/app',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php-base:latest',
                ["WHITELIST_FUNCTIONS=exec \\\n"]
            ],
            [
                // whitelist_functions runtime_config wins
                __DIR__ . '/test_data/whitelist_functions_on_both',
                '',
                '',
                '/app',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php-base:latest',
                ["WHITELIST_FUNCTIONS=exec \\\n"]
            ],
            [
                // Different yaml path
                __DIR__ . '/test_data/different_yaml',
                '',
                'my.yaml',
                '/app',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php-base:latest'
            ],
            [
                // Overrides baseImage
                __DIR__ . '/test_data/simplest',
                'gcr.io/php-mvm-a/php-nginx:latest',
                '',
                '/app',
                'added by the php runtime builder',
                'gcr.io/php-mvm-a/php-nginx:latest'
            ],
            [
                // Has document_root set
                __DIR__ . '/test_data/docroot',
                '',
                '',
                '/app/web',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php-base:latest'
            ],
            [
                // Has document_root set in env_variables
                __DIR__ . '/test_data/docroot_env',
                '',
                '',
                '/app/web',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php-base:latest'
            ],
            [
                // document_root in runtime_config wins
                __DIR__ . '/test_data/docroot_on_both',
                '',
                '',
                '/app/web',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php-base:latest'
            ],
            [
                // Has files already
                __DIR__ . '/test_data/has_files',
                '',
                '',
                '/test',
                'User defined .dockerignore',
                'gcr.io/google_appengine/debian'
            ],
        ];
    }
}
