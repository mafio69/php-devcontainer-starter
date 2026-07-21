#!/usr/bin/env bash
# Jednorazowy skrypt: dopisuje krok HTTP smoke-check (curl + grep na tresci) do
# .github/workflows/smoke.yml na galeziach vanilla/slim/symfony. main pomijamy -
# tam nie ma serwera HTTP (docker-compose.yml na main to nadal "sleep infinity").
# Usun ten plik po uruchomieniu.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

add_step () {
    local branch="$1"
    local marker="$2"

    git checkout "$branch"

    python3 - "$marker" <<'PYEOF'
import re
import sys

marker = sys.argv[1]
path = ".github/workflows/smoke.yml"
with open(path, encoding="utf-8") as f:
    content = f.read()

step = f"""      - name: Sprawdz czy strona faktycznie sie wyswietla (HTTP smoke check)
        run: |
          curl -sf --retry 5 --retry-delay 1 --retry-connrefused http://localhost:8000/ \\
            | grep -q "{marker}" || {{ echo "::error::/ nie zawiera oczekiwanego tekstu ({marker})"; exit 1; }}
          curl -sf --retry 5 --retry-delay 1 --retry-connrefused http://localhost:8000/health \\
            | grep -q '"status":"ok"' || {{ echo "::error::/health nie zwrocil oczekiwanego JSON-a"; exit 1; }}

"""
anchor = "      - name: Run PHPUnit\n"
assert anchor in content, "Nie znaleziono kroku 'Run PHPUnit' w smoke.yml - sprawdz recznie."
content = content.replace(anchor, step + anchor, 1)

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
PYEOF

    git add .github/workflows/smoke.yml
    git commit -m "ci(smoke): dodaj HTTP smoke-check (curl + grep na tresci / i /health)

Dotychczas smoke.yml odpalal phpunit/phpstan W SRODKU kontenera - to testuje logike
aplikacji, ale nigdy nie sprawdza czy 'php -S' faktycznie odpowiada przez siec
(zle mapowanie portu / zly command w docker-compose.yml przeszlyby niezauwazone).
Teraz dodatkowo: curl na localhost:8000/ i /health, sprawdzenie tresci odpowiedzi."
}

add_step vanilla "It works. Vanilla PHP starter"
add_step slim "It works. Slim starter"
add_step symfony "It works. Symfony starter"

echo
echo "Gotowe. Zweryfikuj i zapushuj:"
echo "  for b in vanilla slim symfony; do"
echo "    git checkout \$b"
echo "    docker compose up -d --build"
echo "    docker compose exec -T app composer install"
echo "    sleep 1"
echo "    curl -sf http://localhost:8000/ && echo && curl -sf http://localhost:8000/health && echo"
echo "    docker compose down -v"
echo "  done"
echo "  git push origin vanilla slim symfony"
echo
echo "Usun ten skrypt: rm add-http-smoke-check.sh"
