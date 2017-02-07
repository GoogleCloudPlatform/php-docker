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
namespace Google\Cloud\tests;

class GenFilesTest extends \PHPUnit_Framework_TestCase
{
    static $testDir;

    static public function setUpBeforeClass()
    {
        self::$testDir = tempnam(sys_get_temp_dir(), 'GenFilesTest');
        if (file_exists(self::$testDir)) {
            unlink(self::$testDir);
        }
        mkdir(self::$testDir);
    }

    static public function tearDownAfterClass()
    {
        rmdir(self::$testDir);
    }

    public function setUp()
    {
        // Set default envvar
        putenv('BUILDER_TARGET_IMAGE=' . \GenFiles::DEFAULT_BASE_IMAGE);
        putenv('BUILDER_TARGET_TAG=' . \GenFiles::DEFAULT_TAG);
    }

    public function tearDown()
    {
        $files = array('app.yaml', 'Dockerfile', '.dockerignore');
        foreach ($files as $file) {
            if (file_exists(self::$testDir . '/' . $file)) {
                unlink(self::$testDir . '/' . $file);
            }
        }
    }

    /**
     * @dataProvider dataProvider
     */
    public function testGenFiles(
        $dir,
        $baseImageEnv,
        $tagEnv,
        $expectedDocRoot,
        $expectedDockerIgnore,
        $expectedFrom
    ) {
        // Copy all the files to the test dir
        $files = array('app.yaml', 'Dockerfile', '.dockerignore');
        foreach ($files as $file) {
            if (file_exists($dir . '/' . $file)) {
                copy($dir . '/' . $file, self::$testDir . '/' . $file);
            }
        }
        // Simulate environment variable
        if (!empty($baseImageEnv)) {
            putenv('BUILDER_TARGET_IMAGE=' . $baseImageEnv);
        }
        if (!empty($tagEnv)) {
            putenv('BUILDER_TARGET_TAG=' . $tagEnv);
        }
        $genFiles = new \GenFiles(self::$testDir);
        $genFiles->createDockerfile();

        $dockerfile = file_get_contents(self::$testDir . '/Dockerfile');
        $this->assertTrue($dockerfile !== false, 'Dockerfile should exist');
        $this->assertContains(
            'ENV DOCUMENT_ROOT ' . $expectedDocRoot,
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
                'gcr.io/google-appengine/php:latest'
            ],
            [
                // Overrides BUILDER_TARGET_IMAGE
                __DIR__ . '/test_data/simplest',
                'gcr.io/php-mvm-a/php-nginx',
                '',
                '/app',
                'added by the php runtime builder',
                'gcr.io/php-mvm-a/php-nginx:latest'
            ],
            [
                // Also oerrides BUILDER_TARGET_TAG
                __DIR__ . '/test_data/simplest',
                'gcr.io/php-mvm-a/php-nginx',
                'test',
                '/app',
                'added by the php runtime builder',
                'gcr.io/php-mvm-a/php-nginx:test'
            ],
            [
                // Has document_root set
                __DIR__ . '/test_data/docroot',
                '',
                '',
                '/app/web',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php:latest'
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
