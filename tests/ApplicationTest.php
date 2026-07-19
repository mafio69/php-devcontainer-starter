<?php

declare(strict_types=1);

namespace Tests;

use App\Application;
use PHPUnit\Framework\TestCase;
use Slim\Psr7\Factory\ServerRequestFactory;

final class ApplicationTest extends TestCase
{
    public function testRootRouteReturnsOk(): void
    {
        $response = Application::create()->handle(
            (new ServerRequestFactory())->createServerRequest('GET', '/'),
        );

        self::assertSame(200, $response->getStatusCode());
        self::assertStringContainsString('It works', (string) $response->getBody());
    }

    public function testHealthRouteReturnsJson(): void
    {
        $response = Application::create()->handle(
            (new ServerRequestFactory())->createServerRequest('GET', '/health'),
        );

        self::assertSame(200, $response->getStatusCode());
        self::assertSame('application/json', $response->getHeaderLine('Content-Type'));
    }
}
