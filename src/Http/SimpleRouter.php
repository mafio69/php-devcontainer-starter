<?php

declare(strict_types=1);

namespace App\Http;

/**
 * Intentionally minimal, hand-written router - no external routing library.
 * This is the point of the `vanilla` branch: show what a tiny PHP app looks
 * like without any framework, while staying testable (logic lives here,
 * public/index.php only wires superglobals in and echoes the result).
 */
final class SimpleRouter
{
    /** @var array<string, array<string, callable(): string>> */
    private array $routes = [];

    public function get(string $path, callable $handler): void
    {
        $this->routes['GET'][$path] = $handler;
    }

    public function dispatch(string $method, string $path): string
    {
        $handler = $this->routes[$method][$path] ?? null;

        if ($handler === null) {
            http_response_code(404);

            return "Not found: {$method} {$path}\n";
        }

        return (string) $handler();
    }
}
