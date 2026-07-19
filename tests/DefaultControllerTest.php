<?php

declare(strict_types=1);

namespace Tests;

use App\Kernel;
use PHPUnit\Framework\TestCase;
use Symfony\Component\HttpFoundation\Request;

final class DefaultControllerTest extends TestCase
{
    public function testIndexReturnsOk(): void
    {
        $kernel = new Kernel('test', true);
        $response = $kernel->handle(Request::create('/'));

        self::assertSame(200, $response->getStatusCode());
        self::assertStringContainsString('It works', (string) $response->getContent());
    }

    public function testHealthReturnsJson(): void
    {
        $kernel = new Kernel('test', true);
        $response = $kernel->handle(Request::create('/health'));

        self::assertSame(200, $response->getStatusCode());
        self::assertJson((string) $response->getContent());
    }
}
