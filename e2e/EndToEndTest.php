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

use GuzzleHttp\Client;

class EndToEndTest extends \PHPUnit_Framework_TestCase
{
    private $client;

    const PROJECT_ENV = 'GOOGLE_PROJECT_ID';
    const VERSION_ENV = 'E2E_TEST_VERSION';

    public static function setUpBeforeClass()
    {
        $project_id = getenv(self::PROJECT_ENV);
        $e2e_test_version = getenv(self::VERSION_ENV);
        if ($project_id == false) {
            self::fail('Please set ' . self::PROJECT_ENV . ' env var.');
        }
        if ($e2e_test_version == false) {
            self::fail('Please set ' . self::VERSION_ENV . ' env var.');
        }
        $dockerfilePath = __DIR__ . '/../testapps/php56_e2e/Dockerfile';
        $dockerfile = array(
            "FROM gcr.io/$project_id/php-nginx:$e2e_test_version\n",
            "ENV DOCUMENT_ROOT /app/web\n"
        );
        file_put_contents($dockerfilePath, $dockerfile);
        // TODO: check the return value and maybe retry?
        exec("gcloud -q preview app deploy --version $e2e_test_version"
             . " --project $project_id"
             . ' testapps/php56_e2e/app.yaml');
    }

    public static function tearDownAfterClass()
    {
        // TODO: check the return value and maybe retry?
        exec('gcloud -q preview app modules delete default --version '
             . getenv(self::VERSION_ENV)
             . ' --project '
             . getenv(self::PROJECT_ENV));
    }

    public function setUp()
    {
        $url = sprintf('https://%s-dot-%s.appspot.com/',
                       getenv(self::VERSION_ENV),
                       getenv(self::PROJECT_ENV));
        $this->client = new Client(['base_uri' => $url]);
    }

    public function testIndex()
    {
        // Index serves succesfully with 'Hello World'.
        // This works because the custom DOCUMENT_ROOT is working.
        $resp = $this->client->get('index.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'index.php status code');
        $this->assertContains('Hello World', $resp->getBody()->getContents());
    }

    public function testGoodbye()
    {
        // The URL '/goodbye' works with 'Goodbye World'.
        // This works because the nginx-app.conf is effective.
        $resp = $this->client->get('/goodbye');
        $this->assertEquals('200', $resp->getStatusCode(),
                            '/goodbye status code');
        $this->assertContains('Goodbye World',
                              $resp->getBody()->getContents());
    }

    public function testPhpInfo()
    {
        // Access to phpinfo.php, while phpinfo() should be enabled this time.
        $resp = $this->client->get('phpinfo.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'phpinfo.php status code');
        $this->assertTrue(strlen($resp->getBody()->getContents()) > 1000,
                          'phpinfo() should be enabled.');
    }

    public function testPdoSqlite()
    {
        // Access to pdo_sqlite.php, which should work.
        $resp = $this->client->get('pdo_sqlite.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'pdo_sqlite.php status code');
        $this->assertContains('Hello pdo_sqlite',
                              $resp->getBody()->getContents());
    }
}
