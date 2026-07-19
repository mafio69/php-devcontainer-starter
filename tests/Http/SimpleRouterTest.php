<?php

declare(strict_types=1);

namespace Tests\Http;

use App\Http\SimpleRouter;
use PHPUnit\Framework\TestCase;

final class SimpleRouterTest extends TestCase
{
    public function testDispatchesRegisteredGetRoute(): void
    {
        $router = new SimpleRouter();
        $router->get('/', static fn (): string => 'pong');

        self::assertSame('pong', $router->dispatch('GET', '/'));
    }

    public function testUnknownRouteReturnsNotFoundMessage(): void
    {
        $router = new SimpleRouter();

        self::assertSame("Not found: GET /missing\n", $router->dispatch('GET', '/missing'));
    }
}
