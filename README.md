# php-devcontainer-starter

Starter template for PHP applications with Dev Container, Docker Compose, AI docs, and quality tooling.

## Goal

This repository is a practical PHP starter for local development in Docker / Dev Container.
It is designed as a clean base for future project variants such as Slim, Symfony, and a lightweight vanilla branch.

## Included

- Dev Container configuration
- Docker Compose setup
- Composer project bootstrap
- PSR-4 autoloading
- PHPUnit
- PHPStan
- PHP CS Fixer
- GrumPHP
- GitHub Actions smoke workflow

## Requirements

- Docker
- Docker Compose
- Git
- GitHub account for template usage

## Quick start

```bash
git clone git@github.com:mafio69/php-devcontainer-starter.git
cd php-devcontainer-starter
docker compose up -d --build
docker compose exec -T app composer install
docker compose exec -T app vendor/bin/phpunit
docker compose exec -T app vendor/bin/phpstan analyse
```

## This branch: `vanilla`

No framework, no routing library. `public/index.php` wires PHP superglobals into
`App\Http\SimpleRouter` (`src/Http/SimpleRouter.php`), a hand-written, testable router -
the point of this branch is to show what a minimal PHP app looks like without any
abstraction on top. Open `http://localhost:8000/` after `docker compose up -d --build`.

## Smoke test

The repository contains a GitHub Actions smoke workflow that builds containers and verifies the starter in CI.

Workflow file:

```text
.github/workflows/smoke.yml
```

## Branches

- `main` - common base starter
- `slim` - starter for small and medium applications
- `symfony` - starter for larger applications
- `vanilla` - lightweight PHP variant with selected libraries

## AI docs

Repository-level AI documentation and manifest should live in files such as:

```text
docs/CODING_STANDARDS.md
docs/AGENTS.md
```

## Project direction

The base repository should stay framework-neutral.
Framework-specific structure and dependencies should be added in dedicated branches.

## License

MIT