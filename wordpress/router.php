<?php
/**
 * WordPress用PHP内蔵サーバールーター
 * 
 * 使用方法:
 * php -S localhost:8000 -t . router.php
 */

// 静的ファイルの処理
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$file = __DIR__ . $path;

// 実際のファイルが存在する場合
if (is_file($file)) {
    // 画像、CSS、JSなどの静的ファイルはそのまま返す
    $ext = pathinfo($file, PATHINFO_EXTENSION);
    $staticTypes = ['jpg', 'jpeg', 'png', 'gif', 'svg', 'webp', 'ico', 
                    'css', 'js', 'json', 'woff', 'woff2', 'ttf', 'eot',
                    'pdf', 'zip', 'txt'];
    
    if (in_array($ext, $staticTypes)) {
        return false; // PHPサーバーに処理させる
    }
}

// WordPressのindex.phpを読み込む
$_SERVER['SCRIPT_FILENAME'] = __DIR__ . '/index.php';
$_SERVER['SCRIPT_NAME'] = '/index.php';

// index.phpが存在する場合のみ読み込む
if (file_exists(__DIR__ . '/index.php')) {
    chdir(__DIR__);
    require __DIR__ . '/index.php';
} else {
    http_response_code(404);
    echo '404 - File not found';
}
