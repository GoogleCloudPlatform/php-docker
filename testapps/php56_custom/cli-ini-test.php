<?php

# Just make sure shell_exec succeeds
shell_exec('ls');

file_put_contents('cli-ini-test.txt', 'shell_exec succeeded');
