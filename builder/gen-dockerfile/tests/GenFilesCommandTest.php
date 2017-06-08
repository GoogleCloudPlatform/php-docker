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

    public static $files = [
            'app.yaml',
            'my.yaml',
            'Dockerfile',
            '.dockerignore',
            'composer.json'
    ];

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
        foreach (self::$files as $file) {
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
        $baseImages,
        $appYamlEnv,
        $expectedDocRoot,
        $expectedDockerIgnore,
        $expectedFrom,
        $otherExpectations = [],
        $expectedException = null
    ) {
        if ($baseImages === null) {
            $baseImages =
                [
                    '--php56-image' => 'gcr.io/google-appengine/php56:latest',
                    '--php70-image' => 'gcr.io/google-appengine/php70:latest',
                    '--php71-image' => 'gcr.io/google-appengine/php71:latest',
                ];
        }
        if ($expectedException !== null) {
            $this->setExpectedExceptionRegExp($expectedException);
        }
        // Copy all the files to the test dir
        foreach (self::$files as $file) {
            if (file_exists($dir . '/' . $file)) {
                copy($dir . '/' . $file, self::$testDir . '/' . $file);
            }
        }
        if (!empty($appYamlEnv)) {
            putenv('GAE_APPLICATION_YAML_PATH=' . $appYamlEnv);
        }
        $genFiles = new GenFilesCommand();
        $commandTester = new CommandTester($genFiles);
        $commandTester->execute($baseImages + [
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
                null,
                '',
                '/app',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php71:latest',
                ["GOOGLE_RUNTIME_RUN_COMPOSER_SCRIPT=true \\\n",
                 "FRONT_CONTROLLER_FILE=index.php \\\n",
                 "DETECTED_PHP_VERSION=7.1 \n"
                ]
            ],
            [
                // PHP 5.6
                __DIR__ . '/test_data/php56',
                null,
                '',
                '/app',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php56:latest',
                ["GOOGLE_RUNTIME_RUN_COMPOSER_SCRIPT=true \\\n",
                 "FRONT_CONTROLLER_FILE=index.php \\\n",
                 "DETECTED_PHP_VERSION=5.6 \n"
                ]
            ],
            [
                // PHP 7.0
                __DIR__ . '/test_data/php70',
                null,
                '',
                '/app',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php70:latest',
                ["GOOGLE_RUNTIME_RUN_COMPOSER_SCRIPT=true \\\n",
                 "FRONT_CONTROLLER_FILE=index.php \\\n",
                 "DETECTED_PHP_VERSION=7.0 \n"
                ]
            ],
            [
                // values on env_variables
                __DIR__ . '/test_data/values_only_on_env',
                null,
                '',
                '/app',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php71:latest',
                [
                    "WHITELIST_FUNCTIONS=exec \\\n",
                    "FRONT_CONTROLLER_FILE=app.php",
                    "NGINX_CONF_HTTP_INCLUDE=files/nginx-http.conf",
                    "NGINX_CONF_INCLUDE=files/nginx-app.conf",
                    "NGINX_CONF_OVERRIDE=files/nginx.conf",
                    "PHP_FPM_CONF_OVERRIDE=files/php-fpm.conf",
                    "PHP_INI_OVERRIDE=files/php.ini",
                    "SUPERVISORD_CONF_ADDITION=files/additional-supervisord.conf",
                    "SUPERVISORD_CONF_OVERRIDE=files/supervisord.conf"
                ]
            ],
            [
                // Values in both places will throw an exception.
                __DIR__ . '/test_data/values_on_both',
                null,
                '',
                '/app',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php71:latest',
                [
                    "WHITELIST_FUNCTIONS=exec \\\n",
                    "FRONT_CONTROLLER_FILE=app.php",
                    "NGINX_CONF_HTTP_INCLUDE=files/nginx-http.conf",
                    "NGINX_CONF_INCLUDE=files/nginx-app.conf",
                    "NGINX_CONF_OVERRIDE=files/nginx.conf",
                    "PHP_FPM_CONF_OVERRIDE=files/php-fpm.conf",
                    "PHP_INI_OVERRIDE=files/php.ini",
                    "SUPERVISORD_CONF_ADDITION=files/additional-supervisord.conf",
                    "SUPERVISORD_CONF_OVERRIDE=files/supervisord.conf"
                ],
                '\\RuntimeException'
            ],
            [
                // front_controller_file
                __DIR__ . '/test_data/front_controller_file',
                null,
                '',
                '/app',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php71:latest',
                ["FRONT_CONTROLLER_FILE=app.php \\\n"]
            ],
            [
                // Different yaml path
                __DIR__ . '/test_data/different_yaml',
                null,
                'my.yaml',
                '/app',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php71:latest'
            ],
            [
                // Overrides baseImage
                __DIR__ . '/test_data/simplest',
                [
                    '--php56-image' => 'gcr.io/php-mvm-a/php56:latest',
                    '--php70-image' => 'gcr.io/php-mvm-a/php70:latest',
                    '--php71-image' => 'gcr.io/php-mvm-a/php71:latest',
                ],
                '',
                '/app',
                'added by the php runtime builder',
                'gcr.io/php-mvm-a/php71:latest'
            ],
            [
                // Has document_root set
                __DIR__ . '/test_data/docroot',
                null,
                '',
                '/app/web',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php71:latest'
            ],
            [
                // Has document_root set in env_variables
                __DIR__ . '/test_data/docroot_env',
                null,
                '',
                '/app/web',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php71:latest'
            ],
            [
                // document_root in both will throw exception
                __DIR__ . '/test_data/docroot_on_both',
                null,
                '',
                '/app/web',
                'added by the php runtime builder',
                'gcr.io/google-appengine/php71:latest',
                [],
                '\\RuntimeException'
            ],
            [
                // Has files already
                __DIR__ . '/test_data/has_files',
                null,
                '',
                '/test',
                'User defined .dockerignore',
                'gcr.io/google_appengine/debian'
            ],
        ];
    }
}
