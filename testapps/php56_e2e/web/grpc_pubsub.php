<?php

require_once __DIR__ . '/../vendor/autoload.php';

use Google\Auth\ApplicationDefaultCredentials;

$auth_credentials = ApplicationDefaultCredentials::getCredentials(
    ['https://www.googleapis.com/auth/pubsub']
);

$channel_credentials = Grpc\ChannelCredentials::createSsl(
    file_get_contents(__DIR__ . '/../vendor/grpc/grpc/etc/roots.pem'));

$opts = ['credentials' => $channel_credentials,
         'grpc.ssl_target_name_override' => 'pubsub.googleapis.com'];

$client = new google\pubsub\v1\PublisherClient('pubsub.googleapis.com', $opts);

$deadline = Grpc\Timeval::InfFuture();

$req = new google\pubsub\v1\ListTopicsRequest();
$proj = getenv('GAE_LONG_APP_ID');
$req->setProject('projects/' . $proj);
$call = $client->ListTopics(
    $req,
    [],
    ['call_credentials_callback' =>
     function ($context) use ($auth_credentials) {
         return $auth_credentials->updateMetadata([], $context->service_url);
     }]);

list($response, $status) = $call->wait();

foreach ($response->getTopics() as $topic) {
    echo $topic->getName() . "\n";
}
