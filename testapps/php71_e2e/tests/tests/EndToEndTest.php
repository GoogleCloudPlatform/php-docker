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

use Google\Cloud\TestUtils\EventuallyConsistentTestTrait;
use GuzzleHttp\Client;
use GuzzleHttp\Cookie\CookieJar;

class EndToEndTest extends \PHPUnit_Framework_TestCase
{
    use EventuallyConsistentTestTrait;

    private $client;

    const PROJECT_ENV = 'E2E_PROJECT_ID';
    const VERSION_ENV = 'TAG';
    const SERVICE_ACCOUNT_ENV = 'SERVICE_ACCOUNT_JSON';

    public static function setUpBeforeClass()
    {
        $project_id = getenv(self::PROJECT_ENV);
        $e2e_test_version = getenv(self::VERSION_ENV);
        $service_account_json = getenv(SELF::SERVICE_ACCOUNT_ENV);
        if ($project_id == false) {
            self::fail('Please set ' . self::PROJECT_ENV . ' env var.');
        }
        if ($e2e_test_version == false) {
            self::fail('Please set ' . self::VERSION_ENV . ' env var.');
        }
        if ($service_account_json == false) {
            self::fail('Please set ' . self::SERVICE_ACCOUNT_ENV . ' env var.');
        }

        self::execWithError(
            sprintf(
                'gsutil cp %s /service_account.json',
                $service_account_json
            ),
            'Failed to download the service account json file: '
        );
        self::execWithError(
            sprintf(
                'gcloud config set project %s',
                $project_id
            ),
            'Failed to set project_id: '
        );
        self::execWithError(
            'gcloud -q auth activate-service-account '
                . '--key-file=/service_account.json',
            'Failed to activate the service account: '
        );
        self::deploy($project_id, $e2e_test_version);
    }

    public static function deploy($project_id, $e2e_test_version)
    {
        $command = "gcloud -q app deploy --version $e2e_test_version"
            . " --project $project_id --no-promote"
            . ' ../app.yaml';
        printf("Executing command: '%s'\n", $command);
        for ($i = 0; $i <= 3; $i++) {
            exec(
                $command,
                $output,
                $ret
            );
            if ($ret === 0) {
                return;
            } else {
                echo 'Retrying deployment';
            }
        }
        self::fail('Deployment failed.');
    }


    public static function tearDownAfterClass()
    {
        // TODO: check the return value and maybe retry?
        $cmd = sprintf(
            'gcloud -q app versions delete --service default '
            . '--project %s %s',
            getenv(self::PROJECT_ENV),
            getenv(self::VERSION_ENV)
        );
        exec($cmd);
    }

    private static function execWithError($command, $errorPrefix)
    {
        printf("Executing command: '%s'\n", $command);
        exec(
            $command,
            $output,
            $ret
        );
        if ($ret !== 0) {
            self::fail(
                $errorPrefix
                . implode(PHP_EOL, $output)
            );
        }
    }

    public function setUp()
    {
        $this->eventuallyConsistentRetryCount = 10;

        $url = sprintf('https://%s-dot-%s.appspot.com/',
                       getenv(self::VERSION_ENV),
                       getenv(self::PROJECT_ENV));
        $this->client = new Client(['base_uri' => $url]);
    }

    public function testIndex()
    {
        $this->runEventuallyConsistentTest(function () {
            // Index serves succesfully with 'Hello World'.
            // This works because the custom DOCUMENT_ROOT is working.
            $resp = $this->client->get('index.php');
            $this->assertEquals('200', $resp->getStatusCode(),
                                'index.php status code');
            $this->assertContains('Hello World', $resp->getBody()->getContents());
        });
    }

    public function testHttpsEnv()
    {
        $this->runEventuallyConsistentTest(function () {
            // Check the HTTPS envvar on the server
            $resp = $this->client->get('https-env.php');
            $this->assertEquals('200', $resp->getStatusCode(),
                                'https-env.php status code');
            $this->assertContains('HTTPS: on', $resp->getBody()->getContents());
        });
    }

    public function testGoodbye()
    {
        $this->runEventuallyConsistentTest(function () {
            // The URL '/goodbye' works with 'Goodbye World'.
            // This works because the nginx-app.conf is effective.
            $resp = $this->client->get('/goodbye');
            $this->assertEquals('200', $resp->getStatusCode(),
                                '/goodbye status code');
            $this->assertContains('Goodbye World',
                                  $resp->getBody()->getContents());
        });
    }

    public function testPhpInfo()
    {
        $this->runEventuallyConsistentTest(function () {
            // Access to phpinfo.php, while phpinfo() should be enabled this time.
            $resp = $this->client->get('phpinfo.php');
            $this->assertEquals('200', $resp->getStatusCode(),
                                'phpinfo.php status code');
            $this->assertTrue(strlen($resp->getBody()->getContents()) > 1000,
                              'phpinfo() should be enabled.');
        });
    }

    public function testExec()
    {
        $this->runEventuallyConsistentTest(function () {
            // Access to exec.php; exec() should be enabled.
            $resp = $this->client->get('exec.php');
            $this->assertEquals(
                '200',
                $resp->getStatusCode(),
                'exec.php status code'
            );
            $this->assertContains(
                'exec succeeded.',
                $resp->getBody()->getContents()
            );
        });
    }

    public function testPdoSqlite()
    {
        $this->runEventuallyConsistentTest(function () {
            // Access to pdo_sqlite.php, which should work.
            $resp = $this->client->get('pdo_sqlite.php');
            $this->assertEquals('200', $resp->getStatusCode(),
                                'pdo_sqlite.php status code');
            $this->assertContains('Hello pdo_sqlite',
                                  $resp->getBody()->getContents());
        });
    }

    public function testSessionSaveHandler()
    {
        $this->markTestSkipped('Memcache is not available on env:flex.');
        $this->runEventuallyConsistentTest(function () {
            $resp = $this->client->get('session_save_handler.php');
            $this->assertEquals('200', $resp->getStatusCode(),
                                'session_save_handler status code');
            $this->assertContains('memcached',
                                  $resp->getBody()->getContents());
        });
    }

    public function testSession()
    {
        $this->markTestSkipped('Memcache is not available on env:flex.');
        $this->runEventuallyConsistentTest(function () {
            $jar = new CookieJar();
            $resp = $this->client->get('session.php', ['cookies' => $jar]);
            $this->assertEquals('200', $resp->getStatusCode(),
                                'session.php status code');
            $this->assertEquals('0', $body = $resp->getBody()->getContents());

            $resp = $this->client->get('session.php', ['cookies' => $jar]);
            $this->assertEquals('200', $resp->getStatusCode(),
                                'session.php status code');
            $this->assertEquals('1', $body = $resp->getBody()->getContents());
        });
    }

    public function testGrpcPubsub()
    {
        $this->runEventuallyConsistentTest(function () {
            $resp = $this->client->get('grpc_pubsub.php');
            $this->assertEquals('200', $resp->getStatusCode(),
                                'grpc_pubsub.php status code');
        });
    }
}
