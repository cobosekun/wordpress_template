#!/bin/bash
set -e

echo "=== Database Configuration Debug ==="
echo "DATABASE_URL is set: $([ -z "$DATABASE_URL" ] && echo 'NO' || echo 'YES')"
echo "RENDER_EXTERNAL_URL: $RENDER_EXTERNAL_URL"

# wp-config.phpが存在する場合、環境変数で上書き
if [ -f /var/www/html/wp-config.php ]; then
    # データベース設定
    if [ ! -z "$DATABASE_URL" ]; then
        # DATABASE_URLをパース (mysql://user:pass@host:port/dbname)
        DB_USER=$(echo $DATABASE_URL | sed -e 's/.*:\/\/\([^:]*\):.*@.*/\1/')
        DB_PASS=$(echo $DATABASE_URL | sed -e 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/')
        DB_HOST=$(echo $DATABASE_URL | sed -e 's/.*@\([^:\/]*\).*/\1/')
        DB_NAME=$(echo $DATABASE_URL | sed -e 's/.*\/\([^?]*\).*/\1/')
        
        echo "Parsed DB_HOST: $DB_HOST"
        echo "Parsed DB_NAME: $DB_NAME"
        echo "Parsed DB_USER: $DB_USER"
        
        sed -i "s/define( *'DB_NAME'.*/define( 'DB_NAME', '$DB_NAME' );/" /var/www/html/wp-config.php
        sed -i "s/define( *'DB_USER'.*/define( 'DB_USER', '$DB_USER' );/" /var/www/html/wp-config.php
        sed -i "s/define( *'DB_PASSWORD'.*/define( 'DB_PASSWORD', '$DB_PASS' );/" /var/www/html/wp-config.php
        sed -i "s/define( *'DB_HOST'.*/define( 'DB_HOST', '$DB_HOST' );/" /var/www/html/wp-config.php
        
        echo "Database configuration updated in wp-config.php"
    else
        echo "WARNING: DATABASE_URL not set!"
    fi
    
    # WP_HOME と WP_SITEURL を設定
    if [ ! -z "$RENDER_EXTERNAL_URL" ]; then
        if ! grep -q "WP_HOME" /var/www/html/wp-config.php; then
            sed -i "/define( 'DB_COLLATE'/a define( 'WP_HOME', '$RENDER_EXTERNAL_URL' );\ndefine( 'WP_SITEURL', '$RENDER_EXTERNAL_URL' );" /var/www/html/wp-config.php
            echo "WP_HOME and WP_SITEURL set to: $RENDER_EXTERNAL_URL"
        fi
    fi
else
    echo "WARNING: wp-config.php not found!"
fi

echo "=== Starting Apache ==="

# Apacheのポート設定を環境変数から取得
if [ ! -z "$PORT" ]; then
    sed -i "s/Listen [0-9]*/Listen $PORT/" /etc/apache2/ports.conf
    sed -i "s/:10000/:$PORT/" /etc/apache2/sites-available/000-default.conf
fi

exec "$@"
