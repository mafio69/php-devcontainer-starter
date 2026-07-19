<?php

declare(strict_types=1);

use App\Application;

require dirname(__DIR__) . '/vendor/autoload.php';

Application::create()->run();
