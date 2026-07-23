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

## Smoke test

The repository contains a GitHub Actions smoke workflow that builds containers and verifies the starter in CI.

Workflow file:

```text
.github/workflows/smoke.yml
```

On the `devcontainer` branch, the smoke test also proves the devcontainer works against real,
non-trivial dependencies, not just a toy example:

- `composer.json` requires `mafio69/ovh-ocr` (via a VCS repository - not on Packagist) and
  `mafio69/fast-php-logger` (Packagist). Both resolve through `egress-proxy`, so a successful
  `composer install` is itself a live test of the network allowlist.
- `tests/OcrSmokeTest.php` exercises the real `OcrClient` with a mocked HTTP client (no network,
  no credentials needed) - proves autoload/phpstan/xdebug/phpunit all work on real code.
- `scripts/run-ocr-smoke.php` is a manual (not CI) script that calls the real client and is
  *expected* to fail at the network layer - see `canary/README.md` for why that's deliberate.

## Security model

- Sekrety i model dostępu: `docs/RULES_WORK_SPACE.md` (izolacja katalogów, sekrety poza
  `/workspace`, izolacja sieciowa wychodząca).
- `app`/`nginx` mają zero bezpośredniego dostępu do internetu (`internal: true` na
  `frontend-net`/`backend-net`); cały ruch wychodzący z `app` idzie przez allowlistowany
  `egress-proxy` (`.devcontainer/egress-proxy/squid.conf`).
- `.claude/settings.json` - reguły `deny` dla Claude Code na `.env*`/`secrets/**` (higiena, nie
  twarda granica - patrz komentarz w pliku i `docs/RULES_WORK_SPACE.md`).
- `canary/` - honeypot do wykrywania, czy narzędzia AI próbują faktycznie użyć napotkanego
  "sekretu", nie tylko go odczytać. Zobacz `canary/README.md`.

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