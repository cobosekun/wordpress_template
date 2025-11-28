#!/bin/bash
set -e

# wp-config.phpが存在する場合、環境変数で上書き
if [ -f /var/www/html/wp-config.php ]; then
    # データベース設定
    if [ ! -z "$DATABASE_URL" ]; then
        # DATABASE_URLをパース (mysql://user:pass@host:port/dbname)
        DB_USER=$(echo $DATABASE_URL | sed -e 's/.*:\/\/\([^:]*\):.*@.*/\1/')
        DB_PASS=$(echo $DATABASE_URL | sed -e 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/')
        DB_HOST=$(echo $DATABASE_URL | sed -e 's/.*@\([^:\/]*\).*/\1/')
        DB_NAME=$(echo $DATABASE_URL | sed -e 's/.*\/\([^?]*\).*/\1/')
        
        sed -i "s/define( *'DB_NAME'.*/define( 'DB_NAME', '$DB_NAME' );/" /var/www/html/wp-config.php
        sed -i "s/define( *'DB_USER'.*/define( 'DB_USER', '$DB_USER' );/" /var/www/html/wp-config.php
        sed -i "s/define( *'DB_PASSWORD'.*/define( 'DB_PASSWORD', '$DB_PASS' );/" /var/www/html/wp-config.php
        sed -i "s/define( *'DB_HOST'.*/define( 'DB_HOST', '$DB_HOST' );/" /var/www/html/wp-config.php
    fi
    
    # WP_HOME と WP_SITEURL を設定
    if [ ! -z "$RENDER_EXTERNAL_URL" ]; then
        if ! grep -q "WP_HOME" /var/www/html/wp-config.php; then
            sed -i "/define( 'DB_COLLATE'/a define( 'WP_HOME', '$RENDER_EXTERNAL_URL' );\ndefine( 'WP_SITEURL', '$RENDER_EXTERNAL_URL' );" /var/www/html/wp-config.php
        fi
    fi
fi

# Apacheのポート設定を環境変数から取得
if [ ! -z "$PORT" ]; then
    sed -i "s/Listen [0-9]*/Listen $PORT/" /etc/apache2/ports.conf
    sed -i "s/:10000/:$PORT/" /etc/apache2/sites-available/000-default.conf
fi

exec "$@"
