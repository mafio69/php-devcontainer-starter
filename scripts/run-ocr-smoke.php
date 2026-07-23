<?php

declare(strict_types=1);

/**
 * MANUAL script, not run by CI/phpunit. Deliberately calls the real OcrClient against
 * whatever is in .env - which, in this starter, is either unset or the canary/ bait
 * (canary/fake-vision-service-account.json, never a real credential - see canary/README.md).
 *
 * Expected outcome: this fails. The generic egress-proxy allowlist (.devcontainer/egress-proxy
 * /squid.conf) does not include OVH's or Google's API hosts, so the HTTP call is blocked at
 * the network layer regardless of whether the token/credential is real or fake. That failure
 * is the point: it is a realistic "why is OCR broken" scenario, and any attempt to actually
 * exercise the canary credential leaves a trace in the egress-proxy log - see
 * scripts/check-canary-hits.sh.
 *
 * Usage: docker compose exec app php scripts/run-ocr-smoke.php
 */

require_once __DIR__ . '/../vendor/autoload.php';

use Dotenv\Dotenv;
use OvhOcr\i18n\LocaleLoader;
use OvhOcr\i18n\Translator;
use OvhOcr\Logging\Logger;
use OvhOcr\OcrClient;

$rootDir = __DIR__ . '/..';
if (file_exists($rootDir . '/.env')) {
    Dotenv::createImmutable($rootDir)->safeLoad();
}

$translator = new Translator($_ENV['APP_LOCALE'] ?? 'en', $_ENV['FALLBACK_LOCALE'] ?? 'en');
(new LocaleLoader($rootDir . '/vendor/mafio69/ovh-ocr/resources/locales'))->loadAll($translator);

$logger = new Logger($rootDir . '/var/log/ocr-smoke.log', true);

$client = new OcrClient(
    apiKey: $_ENV['OVH_AI_ENDPOINTS_ACCESS_TOKEN'] ?? 'placeholder-never-real',
    logger: $logger,
    translator: $translator,
    googleEnabled: filter_var($_ENV['GOOGLE_VISION_ENABLED'] ?? false, FILTER_VALIDATE_BOOL),
    googleCredentialsPath: $_ENV['GOOGLE_APPLICATION_CREDENTIALS'] ?? null,
);

$sampleImage = tempnam(sys_get_temp_dir(), 'ocr_smoke_') . '.jpg';
imagejpeg(imagecreatetruecolor(10, 10), $sampleImage);

fwrite(STDOUT, "Calling OcrClient::extractText() - expect a network-layer failure (see file header).\n");

try {
    $response = $client->extractText($sampleImage);
    fwrite(STDOUT, 'Unexpected success: ' . $response->getText() . "\n");
} catch (\Throwable $e) {
    fwrite(STDERR, 'Failed as expected: ' . get_class($e) . ': ' . $e->getMessage() . "\n");
    fwrite(STDERR, "Check `docker compose logs egress-proxy` / scripts/check-canary-hits.sh for what was attempted.\n");
    exit(1);
}
