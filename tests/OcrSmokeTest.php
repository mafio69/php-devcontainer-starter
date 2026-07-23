<?php

declare(strict_types=1);

namespace Tests;

use App\OcrSmoke;
use GuzzleHttp\Client;
use GuzzleHttp\Handler\MockHandler;
use GuzzleHttp\HandlerStack;
use GuzzleHttp\Psr7\Response;
use Mariusz\Logger\DualLogger;
use OvhOcr\i18n\Translator;
use OvhOcr\Logging\Logger;
use OvhOcr\OcrClient;
use PHPUnit\Framework\TestCase;

/**
 * Proves the two real composer dependencies (mafio69/ovh-ocr via VCS, mafio69/fast-php-logger
 * via Packagist) actually resolve, autoload, and run under this devcontainer - phpunit,
 * phpstan and xdebug all exercise real code here, not a toy example. Guzzle is mocked
 * throughout: this test never makes a real network call, needs no real credentials, and
 * would still pass even if the egress-proxy blocked every external host.
 */
final class OcrSmokeTest extends TestCase
{
    private string $tempDir;

    protected function setUp(): void
    {
        $this->tempDir = sys_get_temp_dir() . '/ocr_smoke_' . uniqid();
        mkdir($this->tempDir, 0755, true);
    }

    protected function tearDown(): void
    {
        array_map('unlink', glob($this->tempDir . '/*') ?: []);
        rmdir($this->tempDir);
    }

    public function testRunReturnsMockedText(): void
    {
        $mock = new MockHandler([
            new Response(200, [], json_encode([
                'choices' => [
                    ['message' => ['content' => 'Smoke test text from mocked OVH response']],
                ],
            ])),
        ]);
        $httpClient = new Client(['handler' => HandlerStack::create($mock)]);

        $ocrClient = new OcrClient(
            apiKey: 'test-key-never-real',
            logger: new Logger($this->tempDir . '/ocr.log', true),
            translator: new Translator('en', 'en'),
            modelMap: ['lite' => 'TestModel'],
            modelPriority: ['lite'],
            httpClient: $httpClient,
        );

        $smoke = new OcrSmoke($ocrClient, DualLogger::create($this->tempDir . '/app'));

        $response = $smoke->run($this->createTestImage());

        self::assertSame('Smoke test text from mocked OVH response', $response->getText());
    }

    private function createTestImage(): string
    {
        $path  = $this->tempDir . '/test.jpg';
        $image = imagecreatetruecolor(10, 10);
        imagejpeg($image, $path);

        return $path;
    }
}
