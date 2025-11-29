#!/bin/bash
set -e

echo "=== Railway WordPress Startup ==="
echo "PORT: $PORT"
echo "RAILWAY_PUBLIC_DOMAIN: $RAILWAY_PUBLIC_DOMAIN"

# wp-config.phpが存在する場合、環境変数で上書き
if [ -f /var/www/html/wp-config.php ]; then
    # MySQLの接続情報を環境変数から取得
    if [ ! -z "$MYSQLHOST" ] && [ ! -z "$MYSQLUSER" ] && [ ! -z "$MYSQLPASSWORD" ] && [ ! -z "$MYSQLDATABASE" ]; then
        echo "Configuring MySQL connection..."
        
        # ポート番号を含むホスト設定
        if [ ! -z "$MYSQLPORT" ]; then
            DB_HOST_VALUE="${MYSQLHOST}:${MYSQLPORT}"
        else
            DB_HOST_VALUE="${MYSQLHOST}"
        fi
        
        sed -i "s/define( *'DB_NAME'.*/define( 'DB_NAME', '$MYSQLDATABASE' );/" /var/www/html/wp-config.php
        sed -i "s/define( *'DB_USER'.*/define( 'DB_USER', '$MYSQLUSER' );/" /var/www/html/wp-config.php
        sed -i "s/define( *'DB_PASSWORD'.*/define( 'DB_PASSWORD', '$MYSQLPASSWORD' );/" /var/www/html/wp-config.php
        sed -i "s/define( *'DB_HOST'.*/define( 'DB_HOST', '$DB_HOST_VALUE' );/" /var/www/html/wp-config.php
        
        echo "MySQL configured: $MYSQLUSER@$DB_HOST_VALUE/$MYSQLDATABASE"
    else
        echo "WARNING: MySQL environment variables not set!"
        echo "Required: MYSQLHOST, MYSQLUSER, MYSQLPASSWORD, MYSQLDATABASE"
    fi
    
    # WP_HOME と WP_SITEURL を強制設定（リダイレクトループ対策）
    if [ ! -z "$RAILWAY_PUBLIC_DOMAIN" ]; then
        SITE_URL="https://$RAILWAY_PUBLIC_DOMAIN"
        echo "Site URL will be: $SITE_URL"
        
        # 既存の定義を削除してから追加
        sed -i "/define('RELOCATE'/d" /var/www/html/wp-config.php
        sed -i "/define('WP_HOME'/d" /var/www/html/wp-config.php
        sed -i "/define('WP_SITEURL'/d" /var/www/html/wp-config.php
        sed -i "/define( 'RELOCATE'/d" /var/www/html/wp-config.php
        sed -i "/define( 'WP_HOME'/d" /var/www/html/wp-config.php
        sed -i "/define( 'WP_SITEURL'/d" /var/www/html/wp-config.php
        
        # <?php の直後に追加
        sed -i "/<\?php/a\\
define('RELOCATE', true);\\
define('WP_HOME', '$SITE_URL');\\
define('WP_SITEURL', '$SITE_URL');" /var/www/html/wp-config.php
        echo "WordPress URLs forced to: $SITE_URL"
    fi
else
    echo "WARNING: wp-config.php not found!"
fi

# Apacheのポート設定を環境変数から取得
if [ ! -z "$PORT" ]; then
    echo "Configuring Apache for port $PORT..."
    sed -i "s/Listen .*/Listen $PORT/" /etc/apache2/ports.conf
    sed -i "s/<VirtualHost \*:.*>/<VirtualHost *:$PORT>/" /etc/apache2/sites-available/000-default.conf
fi

echo "=== Starting Apache ==="
exec "$@"
