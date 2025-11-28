<?php
/**
 * Minimal React Theme functions and definitions
 */

// テーマのセットアップ
function minimal_react_theme_setup() {
    // タイトルタグのサポート
    add_theme_support('title-tag');
    
    // 投稿サムネイルのサポート
    add_theme_support('post-thumbnails');
}
add_action('after_setup_theme', 'minimal_react_theme_setup');

// Reactアプリのスクリプトとスタイルを読み込む
function minimal_react_enqueue_scripts() {
    $theme_dir = get_template_directory_uri();
    $dist_dir = $theme_dir . '/dist';
    
    // マニフェストファイルの読み込み
    $manifest_path = get_template_directory() . '/dist/.vite/manifest.json';
    
    if (file_exists($manifest_path)) {
        $manifest = json_decode(file_get_contents($manifest_path), true);
        
        // メインCSSファイル
        if (isset($manifest['src/main.jsx']['css'])) {
            foreach ($manifest['src/main.jsx']['css'] as $css_file) {
                wp_enqueue_style(
                    'minimal-react-app-css',
                    $dist_dir . '/' . $css_file,
                    array(),
                    null
                );
            }
        }
        
        // メインJSファイル
        if (isset($manifest['src/main.jsx']['file'])) {
            wp_enqueue_script(
                'minimal-react-app',
                $dist_dir . '/' . $manifest['src/main.jsx']['file'],
                array(),
                null,
                true
            );
        }
    } else {
        // 開発環境用（Vite dev server）
        wp_enqueue_script(
            'vite-client',
            'http://localhost:5173/@vite/client',
            array(),
            null,
            false
        );
        wp_add_inline_script('vite-client', '', 'before');
        wp_script_add_data('vite-client', 'type', 'module');
        
        wp_enqueue_script(
            'minimal-react-app-dev',
            'http://localhost:5173/src/main.jsx',
            array(),
            null,
            true
        );
        wp_script_add_data('minimal-react-app-dev', 'type', 'module');
    }
}
add_action('wp_enqueue_scripts', 'minimal_react_enqueue_scripts');

// WordPressの不要なヘッダー情報を削除
remove_action('wp_head', 'wp_generator');
remove_action('wp_head', 'wlwmanifest_link');
remove_action('wp_head', 'rsd_link');
remove_action('wp_head', 'wp_shortlink_wp_head');

// WordPressの絵文字スクリプトを削除
remove_action('wp_head', 'print_emoji_detection_script', 7);
remove_action('wp_print_styles', 'print_emoji_styles');
