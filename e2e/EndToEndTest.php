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
use GuzzleHttp\Cookie\CookieJar;

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
        self::deploy($project_id, $e2e_test_version);
    }

    public static function deploy($project_id, $e2e_test_version)
    {
        for ($i = 0; $i <= 3; $i++) {
            exec(
                "gcloud -q preview app deploy --version $e2e_test_version"
                . " --project $project_id"
                . ' testapps/php56_e2e/app.yaml',
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
            'gcloud -q preview app versions delete --service default '
            . '--project %s %s',
            getenv(self::PROJECT_ENV),
            getenv(self::VERSION_ENV)
        );
        exec($cmd);
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

    public function testExec()
    {
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

    public function testSessionSaveHandler()
    {
        $resp = $this->client->get('session_save_handler.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'session_save_handler status code');
        $this->assertContains('memcached',
                              $resp->getBody()->getContents());
    }

    public function testSession()
    {
        $jar = new CookieJar();
        $resp = $this->client->get('session.php', ['cookies' => $jar]);
        $this->assertEquals('200', $resp->getStatusCode(),
                            'session.php status code');
        $this->assertEquals('0', $body = $resp->getBody()->getContents());

        $resp = $this->client->get('session.php', ['cookies' => $jar]);
        $this->assertEquals('200', $resp->getStatusCode(),
                            'session.php status code');
        $this->assertEquals('1', $body = $resp->getBody()->getContents());
    }

    public function testGrpcPubsub()
    {
        $resp = $this->client->get('grpc_pubsub.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'grpc_pubsub.php status code');
    }
}
