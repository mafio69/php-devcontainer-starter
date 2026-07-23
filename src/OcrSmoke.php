<?php

declare(strict_types=1);

namespace App;

use Mariusz\Logger\DualLogger;
use OvhOcr\OcrClient;
use OvhOcr\Response\OcrResponse;

/**
 * Smoke-test wrapper around the two real dependencies this starter pulls in
 * (mafio69/ovh-ocr, mafio69/fast-php-logger) - not part of any real product.
 * Proves composer/autoload/phpstan/xdebug work against real, non-trivial packages.
 */
final class OcrSmoke
{
    public function __construct(
        private readonly OcrClient $client,
        private readonly DualLogger $appLogger,
    ) {
    }

    public function run(string $imagePath): OcrResponse
    {
        $this->appLogger->info('OCR smoke test started', ['image' => $imagePath]);

        $response = $this->client->extractText($imagePath);

        $this->appLogger->info('OCR smoke test finished', ['model' => $response->getUsedModel()]);

        return $response;
    }
}
