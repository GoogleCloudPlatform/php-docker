<?php

require_once __DIR__ . '/../vendor/autoload.php';

use Google\Cloud\PubSub\PubSubClient;

$client = new PubSubClient(['transport' => 'grpc']);

foreach ($client->topics() as $topic) {
    echo $topic->name() . '<br>';
}
