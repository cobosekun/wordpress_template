<?php
// Railway環境でのURL設定
if (getenv('RAILWAY_PUBLIC_DOMAIN')) {
    $site_url = 'https://' . getenv('RAILWAY_PUBLIC_DOMAIN');
    if (!defined('WP_HOME')) {
        define('WP_HOME', $site_url);
    }
    if (!defined('WP_SITEURL')) {
        define('WP_SITEURL', $site_url);
    }
}

// 以下、元のwp-config.phpの内容
