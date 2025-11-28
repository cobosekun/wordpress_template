<?php
/**
 * WordPress用PHP内蔵サーバールーター
 * 
 * 使用方法:
 * php -S localhost:8000 router.php
 */

$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$file = __DIR__ . $path;

// 実際のファイルが存在する場合
if (is_file($file)) {
    // PHPファイルの場合は直接実行
    if (pathinfo($file, PATHINFO_EXTENSION) === 'php') {
        return false; // PHPサーバーに処理させる
    }
    
    // 静的ファイル(CSS, JS, 画像など)もそのまま返す
    $staticTypes = ['jpg', 'jpeg', 'png', 'gif', 'svg', 'webp', 'ico', 
                    'css', 'js', 'json', 'woff', 'woff2', 'ttf', 'eot',
                    'pdf', 'zip', 'txt', 'map'];
    
    $ext = pathinfo($file, PATHINFO_EXTENSION);
    if (in_array($ext, $staticTypes)) {
        return false; // PHPサーバーに処理させる
    }
}

// ディレクトリが存在する場合、index.phpを探す
if (is_dir($file)) {
    $indexFile = rtrim($file, '/') . '/index.php';
    if (is_file($indexFile)) {
        return false; // PHPサーバーがindex.phpを実行
    }
}

// それ以外はWordPressのルーティングに任せる
if (file_exists(__DIR__ . '/index.php')) {
    return false; // PHPサーバーがindex.phpを実行
}

http_response_code(404);
echo '404 - File not found';
