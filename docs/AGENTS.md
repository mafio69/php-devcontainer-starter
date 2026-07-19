# AGENTS.md

## Purpose

This repository is a PHP starter template for Docker / Dev Container based development.
The main branch must stay framework-neutral and focused on reusable foundations.

## Rules

- Prefer simple, practical solutions.
- Do not add framework-specific code to `main`.
- Keep controllers thin and logic explicit.
- Follow SOLID, KISS, DRY, and clean code principles.
- Keep tooling useful, not decorative.
- Prefer small, reviewable changes.

## Quality gates

Before finishing changes, run:

```bash
composer install
vendor/bin/phpunit
vendor/bin/phpstan analyse
vendor/bin/php-cs-fixer fix --dry-run --diff
```

If Docker is used, prefer running commands inside the `app` container.

## Branch intent

- `main` - common foundation
- `slim` - small and medium applications
- `symfony` - larger applications
- `vanilla` - lightweight PHP with selected libraries

## Documentation

Keep README human-oriented.
Keep AGENTS.md short, specific, and authoritative for AI assistants.

## Change policy

- Do not introduce unnecessary dependencies.
- Do not weaken checks just to make CI green.
- Fix root causes before adding workarounds.
- If autoload issues appear, check namespace mapping and run `composer dump-autoload` first.

## DO NOT MAKE CHANGES WITHOUT EXPLICIT PERMISSION
## DO NOT READ, ACCESS, OR EXPOSE SECRETS. DO NOT ASK TO EDIT .ENV* FILES. DO NOT OPEN THEM. DO NOT PRINT THEM. ALWAYS REFER TO THE VARIABLE NAME OR TOKEN NAME, NEVER TO THE SECRET VALUE, TOKEN VALUE, OR PASSWORD. USE DUMMY SECRETS FOR TESTS.
## DO NOT MODIFY ANYTHING INSIDE vendor/
## Current branch: `slim`

Slim 4 app. Route wiring lives in `src/Application.php` (`Application::create()`),
reused by both `public/index.php` and `tests/ApplicationTest.php`. Add new routes there,
not directly in `public/index.php`.
