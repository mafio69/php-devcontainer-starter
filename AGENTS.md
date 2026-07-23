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

## Technical enforcement (this file alone is not enough)

This file is advice to the model, not a technical guarantee — it can be (and has been)
ignored. The actual barrier is `opencode.json` in this repo: `permission.task = deny`
(subagents disabled — a known bug lets them bypass `deny` on `read`/`grep`),
`permission.external_directory = deny`, and `read`/`edit`/`glob`/`grep` deny anything
dot-prefixed except `.local/`, `.github/`, `.opencode/`. `.local/` is the only place for
AI scratch/task files that must never reach git.

Note: `bash` (e.g. `cat .env`) is a separate permission channel not fully covered above —
real production secrets should not live on any machine running a coding agent.
## Current branch: `devcontainer`

Iterating on the devcontainer infra itself before merging into `main` (and, from there, into
`slim`/`symfony`/`vanilla`) - not application code. Two things live on this branch that don't
belong on the others:

- **Network egress isolation**: `frontend-net`/`backend-net` are `internal: true`; all outbound
  HTTP(S) from `app` goes through `.devcontainer/egress-proxy` (squid), allowlisted by domain.
  See `docs/RULES_WORK_SPACE.md` §9. Adding a host: edit `squid.conf`, don't loosen `internal`.
- **Real smoke-test dependencies**: `composer.json` requires `mafio69/ovh-ocr` (via VCS,
  not on Packagist) and `mafio69/fast-php-logger` (Packagist) purely to prove composer/
  phpstan/xdebug/phpunit work against real, non-trivial packages through the egress-proxy - not
  because this starter is an OCR app. See `tests/OcrSmokeTest.php` (mocked HTTP, no network) vs.
  `scripts/run-ocr-smoke.php` (manual, real call, expected to fail - see `canary/README.md`).
