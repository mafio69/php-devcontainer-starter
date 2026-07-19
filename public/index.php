<?php

declare(strict_types=1);

use App\Http\SimpleRouter;

require dirname(__DIR__) . '/vendor/autoload.php';

$router = new SimpleRouter();

$router->get('/', static fn (): string => "It works. Vanilla PHP starter, no framework.\n");

$router->get('/health', static function (): string {
    header('Content-Type: application/json');

    return json_encode(['status' => 'ok'], JSON_THROW_ON_ERROR);
});

echo $router->dispatch(
    $_SERVER['REQUEST_METHOD'] ?? 'GET',
    parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/',
);
