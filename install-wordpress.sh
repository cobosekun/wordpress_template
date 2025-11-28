#!/bin/bash

# WordPress 完全自動インストールスクリプト
# 使用方法: chmod +x install-wordpress.sh && ./install-wordpress.sh

set -e

# 色付き出力用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== WordPress 完全自動インストール ===${NC}\n"

# 現在のディレクトリを取得
INSTALL_DIR=$(pwd)

# 1. 既存のWordPressファイルの確認
if [ -f "wp-config.php" ] && [ -f "wp-load.php" ]; then
    echo -e "${YELLOW}既存のWordPressインストールが検出されました${NC}"
    read -p "続行しますか？ (y/n) [y]: " CONTINUE
    CONTINUE=${CONTINUE:-y}
    if [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ]; then
        echo -e "${RED}インストールを中止しました${NC}"
        exit 1
    fi
else
    # WordPressのダウンロード
    echo -e "${GREEN}WordPress最新版をダウンロード中...${NC}"
    if [ ! -f "wp-load.php" ]; then
        curl -O https://wordpress.org/latest.tar.gz
        tar -xzf latest.tar.gz
        mv wordpress/* .
        rm -rf wordpress latest.tar.gz
        echo -e "${GREEN}✓ WordPressのダウンロードが完了しました${NC}"
    fi
fi

# 2. WP-CLIのインストール確認とインストール
echo -e "\n${GREEN}WP-CLIを確認中...${NC}"
if ! command -v wp &> /dev/null; then
    echo -e "${YELLOW}WP-CLIがインストールされていません。インストールしますか？${NC}"
    read -p "(y/n) [y]: " INSTALL_WPCLI
    INSTALL_WPCLI=${INSTALL_WPCLI:-y}
    
    if [ "$INSTALL_WPCLI" = "y" ] || [ "$INSTALL_WPCLI" = "Y" ]; then
        echo -e "${GREEN}WP-CLIをインストール中...${NC}"
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
        sudo mv wp-cli.phar /usr/local/bin/wp
        echo -e "${GREEN}✓ WP-CLIがインストールされました${NC}"
    else
        echo -e "${YELLOW}WP-CLIなしで続行します${NC}"
    fi
fi

# 3. データベース情報の入力
echo -e "\n${BLUE}=== データベース設定 ===${NC}"
read -p "データベース名 (例: wordpress_db, mysite_db) [wordpress_db]: " DB_NAME
DB_NAME=${DB_NAME:-wordpress_db}

read -p "データベースユーザー名 (例: wordpress_user, wp_admin) [wordpress_user]: " DB_USER
DB_USER=${DB_USER:-wordpress_user}

read -sp "データベースパスワード (例: SecurePass123!): " DB_PASSWORD
echo
if [ -z "$DB_PASSWORD" ]; then
    echo -e "${RED}パスワードは必須です${NC}"
    exit 1
fi

read -p "データベースホスト (例: localhost, 127.0.0.1, db.example.com) [localhost]: " DB_HOST
DB_HOST=${DB_HOST:-localhost}

read -p "テーブル接頭辞 (例: wp_, mysite_, blog_) [wp_]: " TABLE_PREFIX
TABLE_PREFIX=${TABLE_PREFIX:-wp_}

# 4. データベースの作成
echo -e "\n${BLUE}=== データベース作成 ===${NC}"
read -p "データベースを作成しますか？ (y/n) [y]: " CREATE_DB
CREATE_DB=${CREATE_DB:-y}

if [ "$CREATE_DB" = "y" ] || [ "$CREATE_DB" = "Y" ]; then
    read -sp "MySQLのrootパスワード: " MYSQL_ROOT_PASSWORD
    echo
    
    echo -e "${GREEN}データベースを作成中...${NC}"
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'$DB_HOST';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ データベースが作成されました${NC}"
    else
        echo -e "${RED}✗ データベースの作成に失敗しました${NC}"
        exit 1
    fi
fi

# 5. wp-config.phpの作成
echo -e "\n${GREEN}wp-config.phpを作成中...${NC}"

if command -v wp &> /dev/null; then
    # WP-CLIを使用
    wp config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$DB_HOST" \
        --dbprefix="$TABLE_PREFIX" \
        --locale=ja \
        --force \
        --allow-root 2>/dev/null || true
else
    # 手動で作成
    SALT=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
    
    cat > wp-config.php <<EOF
<?php
define( 'DB_NAME', '$DB_NAME' );
define( 'DB_USER', '$DB_USER' );
define( 'DB_PASSWORD', '$DB_PASSWORD' );
define( 'DB_HOST', '$DB_HOST' );
define( 'DB_CHARSET', 'utf8mb4' );
define( 'DB_COLLATE', '' );

$SALT

\$table_prefix = '$TABLE_PREFIX';

define( 'WP_DEBUG', false );

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
EOF
fi

echo -e "${GREEN}✓ wp-config.phpが作成されました${NC}"

# 6. WordPress サイト情報の入力
echo -e "\n${BLUE}=== WordPressサイト設定 ===${NC}"
read -p "サイトURL (例: http://localhost, http://example.com) [http://localhost]: " SITE_URL
SITE_URL=${SITE_URL:-http://localhost}

read -p "サイトタイトル (例: マイブログ, 株式会社サンプル) [My WordPress Site]: " SITE_TITLE
if [ -z "$SITE_TITLE" ]; then
    SITE_TITLE="My WordPress Site"
fi

read -p "管理者ユーザー名 (例: admin, webmaster, your_name) [admin]: " ADMIN_USER
ADMIN_USER=${ADMIN_USER:-admin}

read -sp "管理者パスワード (例: SecurePass123!, MyP@ssw0rd): " ADMIN_PASSWORD
echo
if [ -z "$ADMIN_PASSWORD" ]; then
    ADMIN_PASSWORD=$(openssl rand -base64 12)
    echo -e "${YELLOW}自動生成されたパスワード: $ADMIN_PASSWORD${NC}"
fi

read -p "管理者メールアドレス (例: admin@example.com, your@email.com) [admin@example.com]: " ADMIN_EMAIL
if [ -z "$ADMIN_EMAIL" ]; then
    ADMIN_EMAIL="admin@example.com"
fi

# 7. WordPressのインストール
echo -e "\n${GREEN}WordPressをインストール中...${NC}"

if command -v wp &> /dev/null; then
    # WP-CLIを使用してインストール
    wp core install \
        --url="$SITE_URL" \
        --title="$SITE_TITLE" \
        --admin_user="$ADMIN_USER" \
        --admin_password="$ADMIN_PASSWORD" \
        --admin_email="$ADMIN_EMAIL" \
        --locale=ja \
        --allow-root
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ WordPressがインストールされました${NC}"
        
        # 日本語化
        echo -e "${GREEN}日本語パッケージをインストール中...${NC}"
        wp language core install ja --activate --allow-root 2>/dev/null || true
    else
        echo -e "${YELLOW}⚠ WP-CLIでのインストールに失敗しました。ブラウザから手動でインストールしてください${NC}"
    fi
else
    echo -e "${YELLOW}⚠ WP-CLIが利用できないため、ブラウザから手動でインストールしてください${NC}"
fi

# 8. ファイルパーミッションの設定
echo -e "\n${GREEN}ファイルパーミッションを設定中...${NC}"
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
chmod 600 wp-config.php
mkdir -p wp-content/uploads
chmod 755 wp-content/uploads

echo -e "${GREEN}✓ ファイルパーミッションが設定されました${NC}"

# 8-1. 所有者の設定（オプション）
echo -e "\n${YELLOW}Webサーバーのユーザーに所有権を変更しますか？${NC}"
read -p "変更する場合はユーザー名を入力 (例: www-data, _www, apache) [スキップする場合は Enter]: " WEB_USER

if [ ! -z "$WEB_USER" ]; then
    echo -e "${GREEN}所有者を変更中...${NC}"
    sudo chown -R $WEB_USER:$WEB_USER .
    echo -e "${GREEN}✓ 所有者が ${WEB_USER}:${WEB_USER} に変更されました${NC}"
fi

# 8-2. wp-config.phpのセキュリティ強化
echo -e "\n${GREEN}wp-config.phpのセキュリティ設定を強化中...${NC}"

# wp-config.phpに追加のセキュリティ設定を追加
if grep -q "WP_DEBUG" wp-config.php; then
    # WP_DEBUG の後にセキュリティ設定を追加
    sed -i.bak "/define( 'WP_DEBUG'/a\\
\\
/* セキュリティ設定 */\\
define( 'DISALLOW_FILE_EDIT', true );\\
define( 'WP_POST_REVISIONS', 5 );\\
define( 'AUTOSAVE_INTERVAL', 300 );\\
" wp-config.php
    
    echo -e "${GREEN}✓ wp-config.phpのセキュリティ設定が追加されました${NC}"
    echo -e "  - ファイル編集を無効化 (DISALLOW_FILE_EDIT)"
    echo -e "  - リビジョン数を制限 (WP_POST_REVISIONS)"
    echo -e "  - 自動保存間隔を設定 (AUTOSAVE_INTERVAL)"
fi

# 9. Webサーバーの設定
echo -e "\n${BLUE}=== Webサーバー設定 ===${NC}"
echo -e "${YELLOW}使用するWebサーバーを選択してください:${NC}"
echo -e "1) Apache (推奨)"
echo -e "2) Nginx"
echo -e "3) スキップ（手動設定）"
read -p "選択 (例: 1, 2, 3) [1]: " WEB_SERVER_CHOICE
WEB_SERVER_CHOICE=${WEB_SERVER_CHOICE:-1}

if [ "$WEB_SERVER_CHOICE" = "1" ]; then
    # Apache設定
    echo -e "${GREEN}Apache設定ファイルを作成中...${NC}"
    
    read -p "サーバー名（ドメイン） (例: localhost, example.com, www.mysite.com) [localhost]: " SERVER_NAME
    SERVER_NAME=${SERVER_NAME:-localhost}
    
    APACHE_CONF_DIR=""
    if [ -d "/etc/apache2/sites-available" ]; then
        APACHE_CONF_DIR="/etc/apache2/sites-available"
    elif [ -d "/etc/httpd/conf.d" ]; then
        APACHE_CONF_DIR="/etc/httpd/conf.d"
    fi
    
    if [ ! -z "$APACHE_CONF_DIR" ]; then
        CONF_FILE="$APACHE_CONF_DIR/wordpress.conf"
        
        sudo tee "$CONF_FILE" > /dev/null <<EOF
<VirtualHost *:80>
    ServerName $SERVER_NAME
    DocumentRoot $INSTALL_DIR
    
    <Directory $INSTALL_DIR>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/wordpress_error.log
    CustomLog \${APACHE_LOG_DIR}/wordpress_access.log combined
</VirtualHost>
EOF
        
        echo -e "${GREEN}✓ Apache設定ファイルが作成されました: $CONF_FILE${NC}"
        
        # Apache設定を有効化
        if [ -d "/etc/apache2/sites-available" ]; then
            echo -e "${GREEN}Apache設定を有効化中...${NC}"
            sudo a2ensite wordpress.conf 2>/dev/null || true
            sudo a2enmod rewrite 2>/dev/null || true
            echo -e "${YELLOW}Apacheを再起動してください: sudo systemctl restart apache2${NC}"
        else
            echo -e "${YELLOW}Apacheを再起動してください: sudo systemctl restart httpd${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Apache設定ディレクトリが見つかりません。手動で設定してください${NC}"
    fi
    
elif [ "$WEB_SERVER_CHOICE" = "2" ]; then
    # Nginx設定
    echo -e "${GREEN}Nginx設定ファイルを作成中...${NC}"
    
    read -p "サーバー名（ドメイン） (例: localhost, example.com, www.mysite.com) [localhost]: " SERVER_NAME
    SERVER_NAME=${SERVER_NAME:-localhost}
    
    read -p "PHPのバージョン (例: 8.1, 8.2, 8.3) [8.1]: " PHP_VERSION
    PHP_VERSION=${PHP_VERSION:-8.1}
    
    NGINX_CONF_DIR=""
    if [ -d "/etc/nginx/sites-available" ]; then
        NGINX_CONF_DIR="/etc/nginx/sites-available"
    elif [ -d "/etc/nginx/conf.d" ]; then
        NGINX_CONF_DIR="/etc/nginx/conf.d"
    elif [ -d "/usr/local/etc/nginx/servers" ]; then
        NGINX_CONF_DIR="/usr/local/etc/nginx/servers"
    fi
    
    if [ ! -z "$NGINX_CONF_DIR" ]; then
        CONF_FILE="$NGINX_CONF_DIR/wordpress.conf"
        
        sudo tee "$CONF_FILE" > /dev/null <<EOF
server {
    listen 80;
    server_name $SERVER_NAME;
    root $INSTALL_DIR;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires max;
        log_not_found off;
    }
}
EOF
        
        echo -e "${GREEN}✓ Nginx設定ファイルが作成されました: $CONF_FILE${NC}"
        
        # Nginx設定を有効化
        if [ -d "/etc/nginx/sites-available" ]; then
            echo -e "${GREEN}Nginx設定を有効化中...${NC}"
            sudo ln -sf "$CONF_FILE" /etc/nginx/sites-enabled/ 2>/dev/null || true
        fi
        
        echo -e "${YELLOW}Nginxを再起動してください: sudo systemctl restart nginx${NC}"
    else
        echo -e "${YELLOW}⚠ Nginx設定ディレクトリが見つかりません。手動で設定してください${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Webサーバーの設定をスキップしました${NC}"
fi

# 9-1. .htaccessの作成（Apache用）
if [ ! -f ".htaccess" ]; then
    echo -e "\n${GREEN}.htaccessを作成中...${NC}"
    cat > .htaccess <<'EOF'
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress

# セキュリティ設定
<files wp-config.php>
order allow,deny
deny from all
</files>

# ディレクトリ一覧表示の無効化
Options -Indexes

# XMLRPCの保護
<Files xmlrpc.php>
order deny,allow
deny from all
</Files>
EOF
    echo -e "${GREEN}✓ .htaccessが作成されました${NC}"
fi

# 10. セキュリティ設定（オプション）
echo -e "\n${YELLOW}セキュリティファイルを削除しますか？ (readme.html, license.txt)${NC}"
read -p "(y/n) [y]: " REMOVE_FILES
REMOVE_FILES=${REMOVE_FILES:-y}

if [ "$REMOVE_FILES" = "y" ] || [ "$REMOVE_FILES" = "Y" ]; then
    rm -f readme.html license.txt
    echo -e "${GREEN}✓ 不要なファイルを削除しました${NC}"
fi

# 11. 完了メッセージ
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}   インストールが完了しました！${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${BLUE}サイト情報:${NC}"
echo -e "  URL: ${GREEN}$SITE_URL${NC}"
echo -e "  管理画面: ${GREEN}$SITE_URL/wp-admin/${NC}"
echo -e "  サイトタイトル: ${GREEN}$SITE_TITLE${NC}\n"

echo -e "${BLUE}管理者アカウント:${NC}"
echo -e "  ユーザー名: ${GREEN}$ADMIN_USER${NC}"
echo -e "  パスワード: ${GREEN}$ADMIN_PASSWORD${NC}"
echo -e "  メール: ${GREEN}$ADMIN_EMAIL${NC}\n"

echo -e "${BLUE}データベース情報:${NC}"
echo -e "  名前: ${GREEN}$DB_NAME${NC}"
echo -e "  ユーザー: ${GREEN}$DB_USER${NC}"
echo -e "  ホスト: ${GREEN}$DB_HOST${NC}\n"

echo -e "${YELLOW}次のステップ:${NC}"
if [ "$WEB_SERVER_CHOICE" = "1" ]; then
    echo -e "1. Apacheを再起動: ${GREEN}sudo systemctl restart apache2${NC}"
    echo -e "2. ブラウザで ${GREEN}$SITE_URL${NC} にアクセス"
elif [ "$WEB_SERVER_CHOICE" = "2" ]; then
    echo -e "1. Nginxを再起動: ${GREEN}sudo systemctl restart nginx${NC}"
    echo -e "2. ブラウザで ${GREEN}$SITE_URL${NC} にアクセス"
else
    echo -e "1. Webサーバー（Apache/Nginx）を設定してください"
    echo -e "2. ブラウザで ${GREEN}$SITE_URL${NC} にアクセス"
fi
echo -e "3. 管理画面 ${GREEN}$SITE_URL/wp-admin/${NC} でログイン"
echo -e "4. テーマとプラグインをカスタマイズ\n"

echo -e "${YELLOW}セキュリティ推奨:${NC}"
echo -e "- SSL/TLS証明書の設定 (Let's Encrypt推奨)"
echo -e "  ${GREEN}sudo certbot --apache -d $SERVER_NAME${NC} (Apache)"
echo -e "  ${GREEN}sudo certbot --nginx -d $SERVER_NAME${NC} (Nginx)"
echo -e "- 定期的なバックアップの設定"
echo -e "- セキュリティプラグインのインストール (Wordfence, iThemes Security等)"
echo -e "- ファイアウォールの設定 (UFW, fail2ban等)\n"

echo -e "${BLUE}設定ファイルの場所:${NC}"
echo -e "  WordPress: ${GREEN}$INSTALL_DIR${NC}"
echo -e "  wp-config.php: ${GREEN}$INSTALL_DIR/wp-config.php${NC}"
if [ "$WEB_SERVER_CHOICE" = "1" ] || [ "$WEB_SERVER_CHOICE" = "2" ]; then
    echo -e "  Webサーバー設定: ${GREEN}$CONF_FILE${NC}"
fi
echo -e ""
