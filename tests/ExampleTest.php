<?php

declare(strict_types=1);

namespace Tests;

use App\Example;
use PHPUnit\Framework\TestCase;

final class ExampleTest extends TestCase
{
    public function testPingReturnsPong(): void
    {
        self::assertSame('pong', new Example()->ping());
    }
}
