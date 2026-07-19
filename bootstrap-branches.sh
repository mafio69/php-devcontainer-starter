#!/usr/bin/env bash
# Jednorazowy skrypt: tworzy galezie `slim` i `symfony` z `main` i wypelnia je
# minimalnym szkieletem. `vanilla` jest juz zacommitowana (zrobiona przez Claude).
# Usun ten plik po uruchomieniu (nie jest czescia zadnej galezi na stale).
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

git fetch origin >/dev/null 2>&1 || true

# ---------------------------------------------------------------------------
# slim
# ---------------------------------------------------------------------------
git checkout main
git checkout -b slim

git rm -f src/Example.php tests/ExampleTest.php

mkdir -p src public tests

cat > composer.json <<'EOF'
{
    "name": "mafio69/php-devcontainer-starter",
    "description": "Starter template for PHP applications with Dev Container, AI docs, and quality tooling.",
    "type": "project",
    "license": "MIT",
    "autoload": {
        "psr-4": {
            "App\\": "src/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "Tests\\": "tests/"
        }
    },
    "authors": [
        {
            "name": "Mariusz Franciszczak",
            "email": "mariusz.franciszczak@gmail.com"
        }
    ],
    "minimum-stability": "stable",
    "prefer-stable": true,
    "require": {
        "php": "^8.4",
        "slim/psr7": "^1.7",
        "slim/slim": "^4.14"
    },
    "require-dev": {
        "phpro/grumphp": "^2.22",
        "phpstan/phpstan": "^2.2",
        "friendsofphp/php-cs-fixer": "^3.95",
        "phpunit/phpunit": "^13.2"
    },
    "scripts": {
        "test": "phpunit",
        "stan": "phpstan analyse",
        "fix": "php-cs-fixer fix",
        "check-cs": "php-cs-fixer fix --dry-run --diff"
    },
    "config": {
        "allow-plugins": {
            "phpro/grumphp": true
        },
        "sort-packages": true
    }
}
EOF

cat > src/Application.php <<'EOF'
<?php

declare(strict_types=1);

namespace App;

use Slim\App;
use Slim\Factory\AppFactory;

/**
 * Thin factory around Slim's App - kept separate from public/index.php so it
 * can be reused as-is in tests (build the app, feed it a fake request,
 * assert on the response) without booting a real HTTP server.
 */
final class Application
{
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

        return $app;
    }
}
EOF

cat > public/index.php <<'EOF'
<?php

declare(strict_types=1);

use App\Application;

require dirname(__DIR__) . '/vendor/autoload.php';

Application::create()->run();
EOF

cat > tests/ApplicationTest.php <<'EOF'
<?php

declare(strict_types=1);

namespace Tests;

use App\Application;
use PHPUnit\Framework\TestCase;
use Slim\Psr7\Factory\RequestFactory;

final class ApplicationTest extends TestCase
{
    public function testRootRouteReturnsOk(): void
    {
        $response = Application::create()->handle(
            (new RequestFactory())->createRequest('GET', '/'),
        );

        self::assertSame(200, $response->getStatusCode());
        self::assertStringContainsString('It works', (string) $response->getBody());
    }

    public function testHealthRouteReturnsJson(): void
    {
        $response = Application::create()->handle(
            (new RequestFactory())->createRequest('GET', '/health'),
        );

        self::assertSame(200, $response->getStatusCode());
        self::assertSame('application/json', $response->getHeaderLine('Content-Type'));
    }
}
EOF

cat > docker-compose.yml <<'EOF'
services:
  app:
    build:
      context: .
      dockerfile: .devcontainer/Dockerfile
    volumes:
      - .:/workspace:cached
    working_dir: /workspace
    # Wbudowany serwer PHP, index.php jako router script (obsluguje tez sciezki bez
    # fizycznego pliku, np. /health). Ten sam wzorzec powtarza sie w kazdej galezi
    # (vanilla/slim/symfony) - rozni sie tylko zawartosc public/index.php.
    command: php -S 0.0.0.0:8000 -t public public/index.php
    ports:
      - "8000:8000"
    extra_hosts:
      - "host.docker.internal:host-gateway"
EOF

sed -i 's/branches: \[main\]/branches: [main, vanilla, slim, symfony]/' .github/workflows/smoke.yml

sed -i "s#^It is designed as a clean base.*#It is designed as a clean base for future project variants such as Slim, Symfony, and a lightweight vanilla branch.\n\n## This branch: \`slim\`\n\nUses [Slim 4](https://www.slimframework.com/) + \`slim/psr7\`. App wiring lives in \`src/Application.php\` (reused by \`public/index.php\` and by tests - build the app, feed it a fake PSR-7 request, assert on the response). Open http://localhost:8000/ after \`docker compose up -d --build\`.#" README.md

cat >> docs/AGENTS.md <<'EOF'

## Current branch: `slim`

Slim 4 app. Route wiring lives in `src/Application.php` (`Application::create()`),
reused by both `public/index.php` and `tests/ApplicationTest.php`. Add new routes there,
not directly in `public/index.php`.
EOF

git add -A
git commit -m "feat(slim): Slim 4 starter (Application::create() + php -S dev server)

- src/Application.php: Slim app factory, shared by public/index.php and tests
  (functional tests build the app and feed it a fake PSR-7 request, no real
  HTTP server needed).
- docker-compose.yml: same php -S pattern as vanilla/symfony branches.
- smoke.yml: trigger on vanilla/slim/symfony in addition to main.
- Removed src/Example.php + tests/ExampleTest.php (superseded by the real
  Slim example)."

# ---------------------------------------------------------------------------
# symfony
# ---------------------------------------------------------------------------
git checkout main
git checkout -b symfony

git rm -f src/Example.php tests/ExampleTest.php

mkdir -p src/Controller config/packages public tests

cat > composer.json <<'EOF'
{
    "name": "mafio69/php-devcontainer-starter",
    "description": "Starter template for PHP applications with Dev Container, AI docs, and quality tooling.",
    "type": "project",
    "license": "MIT",
    "autoload": {
        "psr-4": {
            "App\\": "src/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "Tests\\": "tests/"
        }
    },
    "authors": [
        {
            "name": "Mariusz Franciszczak",
            "email": "mariusz.franciszczak@gmail.com"
        }
    ],
    "minimum-stability": "stable",
    "prefer-stable": true,
    "require": {
        "php": "^8.4",
        "symfony/dotenv": "8.1.*",
        "symfony/framework-bundle": "8.1.*",
        "symfony/runtime": "8.1.*",
        "symfony/yaml": "8.1.*"
    },
    "require-dev": {
        "phpro/grumphp": "^2.22",
        "phpstan/phpstan": "^2.2",
        "friendsofphp/php-cs-fixer": "^3.95",
        "phpunit/phpunit": "^13.2"
    },
    "scripts": {
        "test": "phpunit",
        "stan": "phpstan analyse",
        "fix": "php-cs-fixer fix",
        "check-cs": "php-cs-fixer fix --dry-run --diff"
    },
    "config": {
        "allow-plugins": {
            "phpro/grumphp": true,
            "symfony/runtime": true
        },
        "sort-packages": true
    },
    "extra": {
        "runtime": {}
    }
}
EOF

cat > config/bundles.php <<'EOF'
<?php

return [
    Symfony\Bundle\FrameworkBundle\FrameworkBundle::class => ['all' => true],
];
EOF

cat > config/packages/framework.yaml <<'EOF'
# see https://symfony.com/doc/current/reference/configuration/framework.html
framework:
    secret: '%env(APP_SECRET)%'

when@test:
    framework:
        test: true
EOF

cat > config/routes.yaml <<'EOF'
# Methods with the #[Route] attribute are automatically imported.
# See also https://symfony.com/doc/current/routing.html
controllers:
    resource: routing.controllers
EOF

cat > config/services.yaml <<'EOF'
services:
    _defaults:
        autowire: true
        autoconfigure: true

    App\:
        resource: '../src/'
        exclude:
            - '../src/Kernel.php'
EOF

cat > src/Kernel.php <<'EOF'
<?php

declare(strict_types=1);

namespace App;

use Symfony\Bundle\FrameworkBundle\Kernel\MicroKernelTrait;
use Symfony\Component\HttpKernel\Kernel as BaseKernel;

class Kernel extends BaseKernel
{
    use MicroKernelTrait;
}
EOF

cat > src/Controller/DefaultController.php <<'EOF'
<?php

declare(strict_types=1);

namespace App\Controller;

use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class DefaultController
{
    #[Route('/', name: 'app_index', methods: ['GET'])]
    public function index(): Response
    {
        return new Response("It works. Symfony starter.\n");
    }

    #[Route('/health', name: 'app_health', methods: ['GET'])]
    public function health(): JsonResponse
    {
        return new JsonResponse(['status' => 'ok']);
    }
}
EOF

cat > public/index.php <<'EOF'
<?php

use App\Kernel;

require_once dirname(__DIR__).'/vendor/autoload_runtime.php';

return static function (array $context) {
    return new Kernel($context['APP_ENV'], (bool) $context['APP_DEBUG']);
};
EOF

cat > phpunit.xml.dist <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<phpunit bootstrap="vendor/autoload.php" colors="true">
    <php>
        <env name="APP_ENV" value="test" force="true"/>
        <env name="APP_SECRET" value="test-secret-do-not-use-in-prod" force="true"/>
        <env name="KERNEL_CLASS" value="App\Kernel"/>
    </php>
    <testsuites>
        <testsuite name="Application Test Suite">
            <directory>tests</directory>
        </testsuite>
    </testsuites>
</phpunit>
EOF

cat > tests/DefaultControllerTest.php <<'EOF'
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
EOF

cat > .env.example <<'EOF'
APP_ENV=dev
APP_DEBUG=1
APP_SECRET=change-me-generate-with-openssl-rand-hex-16
EOF

cat >> .gitignore <<'EOF'

# symfony branch
/.env
/.env.local
/.env.*.local
/var/
EOF

cat > docker-compose.yml <<'EOF'
services:
  app:
    build:
      context: .
      dockerfile: .devcontainer/Dockerfile
    volumes:
      - .:/workspace:cached
    working_dir: /workspace
    command: php -S 0.0.0.0:8000 -t public public/index.php
    ports:
      - "8000:8000"
    extra_hosts:
      - "host.docker.internal:host-gateway"
EOF

sed -i 's/branches: \[main\]/branches: [main, vanilla, slim, symfony]/' .github/workflows/smoke.yml

cat >> docs/AGENTS.md <<'EOF'

## Current branch: `symfony`

Minimal Symfony skeleton (framework-bundle + runtime only, no Doctrine/security/twig
yet - add them when the real app needs them, not speculatively). Routes are
attribute-based on controllers (`src/Controller/`), autowired via `config/services.yaml`.
Copy `.env.example` to `.env` and set a real `APP_SECRET` before running outside tests.
EOF

git add -A
git commit -m "feat(symfony): minimal Symfony 8.1 skeleton (framework-bundle + runtime only)

- config/bundles.php + framework.yaml + routes.yaml + services.yaml: standard
  MicroKernelTrait layout, same shape as devbrain's own backend/config/.
- src/Kernel.php, src/Controller/DefaultController.php (#[Route] attributes).
- phpunit.xml.dist: APP_SECRET/APP_ENV injected via <env>, no dotenv needed
  in tests - DefaultControllerTest boots the real Kernel directly.
- .env.example + .gitignore entries (/.env, /var/) - no real secret committed.
- docker-compose.yml / smoke.yml: same pattern as vanilla/slim branches.
- Removed src/Example.php + tests/ExampleTest.php (superseded)."

echo
echo "Gotowe. Zweryfikuj lokalnie kazda galaz:"
echo "  for b in vanilla slim symfony; do"
echo "    git checkout \$b && docker compose up -d --build && \\"
echo "    docker compose exec -T app composer install && \\"
echo "    docker compose exec -T app vendor/bin/phpunit && \\"
echo "    docker compose exec -T app vendor/bin/phpstan analyse"
echo "  done"
echo
echo "Potem: git push origin vanilla slim symfony"
echo
echo "Na koniec usun ten skrypt: rm bootstrap-branches.sh"
