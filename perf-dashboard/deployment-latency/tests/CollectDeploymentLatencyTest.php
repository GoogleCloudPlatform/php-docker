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

namespace Google\Cloud\PerfDashBoard;

use Google\Cloud\BigQuery\BigQueryClient;
use PHPUnit\Framework\TestCase;

class CollectDeploymentLatencyTest extends TestCase
{
    const DEPLOYMENT_MAX_RETRY = 5;
    const DATASET_ID = 'deployment_latency';
    const TABLE_ID = 'flex_deployments';

    /* @var BigQueryClient */
    private static $bigQuery;

    /**
     * @var string phpVersion The PHP version in a form of Major.Minor
     * @return string a path to the directory
     */
    private static function createApp($phpVersion)
    {
        $tempDir = tempnam(sys_get_temp_dir(), 'app');
        unlink($tempDir);
        mkdir($tempDir);
        mkdir($tempDir . '/web');
        copy(__DIR__ . '/files/app.yaml', $tempDir . '/app.yaml');
        copy(__DIR__ . '/files/web/index.php', $tempDir . '/web/index.php');
        chdir($tempDir);
        $composerJSON = [
            'require' => [
                'php' => $phpVersion . '.*',
                'google/cloud' => '*'
            ]
        ];
        file_put_contents('composer.json', json_encode($composerJSON));
        return $tempDir;
    }

    public function testDeploymentLatency()
    {
        $phpVersions = [
            '7.1',
            '7.2'
        ];
        $types = [
            'ubuntu16'
        ];
        $gcloudTrack = getenv('GCLOUD_TRACK') === 'beta' ? 'beta' : '';
        foreach ($phpVersions as $phpVersion) {
            foreach ($types as $type) {
                $dir = self::createApp($phpVersion);
                chdir($dir);
                try {
                    $reportName = sprintf('%s-%s', $type, $phpVersion);
                    $failureCount = 0;
                    $command = 'gcloud -q ' . $gcloudTrack . ' app deploy'
                        . ' --version '
                        . str_replace('.', '', $reportName)
                        . ' --no-stop-previous-version --no-promote';
                    $configCmd = 'gcloud config set app/use_runtime_builders true';
                    self::execWithError($configCmd, 'runtime-builders-config');
                    $f = fopen('app.yaml', 'a+');
                    fwrite($f, "  base_os: $type\n");
                    $latency = 0.0;
                    while ($failureCount < self::DEPLOYMENT_MAX_RETRY) {
                        $start = microtime(true);
                        $ret = self::execWithResult($command);
                        if ($ret === 0) {
                            $latency = microtime(true) - $start;
                            break;
                        }
                        $failureCount++;
                    }
                    self::$bigQuery = self::createBigQueryClient();
                    $dataset = self::$bigQuery->dataset(self::DATASET_ID);
                    $table = $dataset->table(self::TABLE_ID);
                    $timestamp = self::$bigQuery->timestamp(new \DateTime());
                    $row = [
                        'deployment_latency_seconds' => $latency,
                        'report_name' => $reportName,
                        'failure_count' => $failureCount,
                        't' => $timestamp
                    ];
                    $table->insertRow($row);
                    echo "Inserted: $reportName failure: $failureCount" . PHP_EOL;
                    echo "Inserted: $reportName latency: $latency" . PHP_EOL;
                } finally {
                    $command = 'gcloud -q ' . $gcloudTrack . ' app versions delete '
                        . str_replace('.', '', $reportName);
                    $failureCount = 0;
                    while ($failureCount < self::DEPLOYMENT_MAX_RETRY) {
                        $start = microtime(true);
                        $ret = self::execWithResult($command);
                        if ($ret === 0) {
                            break;
                        }
                        $failureCount++;
                    }
                    exec("rm -rf $dir");
                }
            }
        }
    }

    private static function createBigQueryClient()
    {
        $context = stream_context_create(
            [
                'http' => [
                    'method' => 'GET',
                    'header' => 'Metadata-Flavor: Google'
                ]
            ]
        );
        $url = 'http://metadata.google.internal/computeMetadata/'
            . 'v1/instance/service-accounts/default/token';
        $token = json_decode(file_get_contents($url, false, $context), true);

        return new BigQueryClient(
            [
                'projectId' => getenv('GOOGLE_PROJECT_ID'),
                'accessToken' => $token['access_token']
            ]
        );
    }

    private static function execWithError($command, $errorPrefix)
    {
        $ret = self::execWithResult($command);
        if ($ret !== 0) {
            self::fail(
                $errorPrefix
                . implode(PHP_EOL, $output)
            );
        }
    }

    private static function execWithResult($command)
    {
        printf("Executing command: '%s'\n", $command);
        exec(
            $command,
            $output,
            $ret
        );
        return $ret;
    }
}
