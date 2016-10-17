<?php

require_once __DIR__ . '/../vendor/autoload.php';

use Google\Auth\ApplicationDefaultCredentials;

syslog(LOG_INFO, 'A');

$auth_credentials = ApplicationDefaultCredentials::getCredentials(
    ['https://www.googleapis.com/auth/pubsub']
);

syslog(LOG_INFO, 'B');

$channel_credentials = Grpc\ChannelCredentials::createSsl(
    file_get_contents(__DIR__ . '/../vendor/grpc/grpc/etc/roots.pem'));

syslog(LOG_INFO, 'C');

$opts = ['credentials' => $channel_credentials,
         'grpc.ssl_target_name_override' => 'pubsub.googleapis.com'];

syslog(LOG_INFO, 'D');

$client = new google\pubsub\v1\PublisherClient('pubsub.googleapis.com', $opts);

syslog(LOG_INFO, 'E');

$deadline = Grpc\Timeval::InfFuture();

syslog(LOG_INFO, 'F');

$req = new google\pubsub\v1\ListTopicsRequest();

syslog(LOG_INFO, 'G');

$proj = getenv('GAE_LONG_APP_ID');

syslog(LOG_INFO, 'H');

$req->setProject('projects/' . $proj);

syslog(LOG_INFO, 'I');

$call = $client->ListTopics(
    $req,
    [],
    ['call_credentials_callback' =>
     function ($context) use ($auth_credentials) {
         return $auth_credentials->updateMetadata([], $context->service_url);
     }]);

syslog(LOG_INFO, 'J');

list($response, $status) = $call->wait();

syslog(LOG_INFO, 'K');

foreach ($response->getTopics() as $topic) {
    echo $topic->getName() . "\n";
}
