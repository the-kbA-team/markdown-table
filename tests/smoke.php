<?php

require __DIR__ . '/../vendor/autoload.php';

$table = new \kbATeam\MarkdownTable\Table(['Name']);
$actual = $table->getString([['Name' => 'Ada']]);
$expected = 'Name' . PHP_EOL . '----' . PHP_EOL . 'Ada ' . PHP_EOL;

if ($actual !== $expected) {
    fwrite(STDERR, "Unexpected table output:\n" . $actual);
    exit(1);
}
