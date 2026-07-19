<?php

declare(strict_types=1);

namespace App;

use Psr\Container\ContainerInterface;
use Slim\App;
use Slim\Factory\AppFactory;

/**
 * Thin factory around Slim's App - kept separate from public/index.php so it
 * can be reused as-is in tests (build the app, feed it a fake request,
 * assert on the response) without booting a real HTTP server.
 */
final class Application
{
    /** @return App<ContainerInterface|null> */
    public static function create(): App
    {
        $app = AppFactory::create();

        $app->get('/', static function ($request, $response) {
            $response->getBody()->write("It works. Slim starter.\n");

            return $response;
        });

        $app->get('/health', static function ($request, $response) {
            $response->getBody()->write(json_encode(['status' => 'ok'], JSON_THROW_ON_ERROR));

            return $response->withHeader('Content-Type', 'application/json');
        });

        // Slim\App's template is invariant, not covariant (see
        // https://phpstan.org/blog/whats-up-with-template-covariant) - PHPStan can't
        // prove this matches AppFactory::create()'s own generic instantiation
        // byte-for-byte even though it's correct at runtime.
        // @phpstan-ignore-next-line return.type
        return $app;
    }
}
