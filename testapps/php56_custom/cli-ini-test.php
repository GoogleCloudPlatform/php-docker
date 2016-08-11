<?php

# Just make sure system succeeds
system('ls');

file_put_contents('cli-ini-test.txt', 'system succeeded');
