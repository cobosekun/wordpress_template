# WordPress CLI セットアップガイド

WordPressのベアメタル環境をCLIで簡単にセットアップできるスクリプトを用意しました。

## 利用可能なスクリプト

### 1. `setup.sh` - 基本セットアップスクリプト

データベース作成、wp-config.php設定、パーミッション設定を対話形式で実行します。

```bash
chmod +x setup.sh
./setup.sh
```

**実行内容:**
- データベース情報の入力（対話形式）
- MySQLデータベースとユーザーの作成
- セキュリティキーの自動生成
- wp-config.phpの作成
- ファイルパーミッションの設定
- 所有者の変更（オプション）

**必要な情報:**
- データベース名（デフォルト: wordpress_db）
- データベースユーザー名（デフォルト: wordpress_user）
- データベースパスワード（必須）
- データベースホスト（デフォルト: localhost）
- MySQLのrootパスワード（データベース作成時）

---

### 2. `install-wordpress.sh` - 完全自動インストールスクリプト

WordPress本体のダウンロードからインストールまでを一括実行します。

```bash
chmod +x install-wordpress.sh
./install-wordpress.sh
```

**実行内容:**
- WordPress最新版のダウンロード（必要な場合）
- WP-CLIのインストール確認とインストール（オプション）
- データベースの作成
- wp-config.phpの作成（セキュリティキー自動生成）
- WordPressのインストール（WP-CLI使用時）
- 日本語パッケージのインストール
- ファイルパーミッションの設定
- 所有者の変更（Webサーバーユーザー）
- wp-config.phpのセキュリティ強化
  - ファイル編集無効化
  - リビジョン数制限
  - 自動保存間隔設定
- Webサーバー設定（Apache/Nginx）
- .htaccessの作成（セキュリティ設定込み）
- セキュリティファイルの削除（オプション）

**必要な情報:**（すべて入力例付き）
- データベース情報（名前、ユーザー、パスワード、ホスト）
- サイトURL（デフォルト: http://localhost）
- サイトタイトル（デフォルト: My WordPress Site）
- 管理者アカウント情報（ユーザー名、パスワード、メール）
- Webサーバー選択（Apache推奨/Nginx/スキップ）
- サーバー名（ドメイン名）

---

## クイックスタート

### 最小構成での実行

```bash
# 1. setup.shで基本設定のみ実行
./setup.sh

# データベース名: wordpress_db（Enter）
# ユーザー名: wordpress_user（Enter）
# パスワード: your_password（入力）
# ホスト: localhost（Enter）
# MySQLルートパスワード: root_password（入力）
```

### 完全自動インストール（推奨）

```bash
# install-wordpress.shで完全自動インストール
./install-wordpress.sh

# すべての入力項目に例が表示されます
# デフォルト値を使う場合はEnterキーで進めます
# WP-CLIがある場合は完全自動でインストール完了
```

**主な質問項目:**
1. データベース名 (例: wordpress_db, mysite_db) [wordpress_db]
2. データベースユーザー名 (例: wordpress_user, wp_admin) [wordpress_user]
3. データベースパスワード (例: SecurePass123!)
4. Webサーバー選択: 1) Apache (推奨) / 2) Nginx / 3) スキップ [1]
5. サイトURL (例: http://localhost, http://example.com) [http://localhost]
6. サイトタイトル (例: マイブログ, 株式会社サンプル)
7. 管理者情報（ユーザー名、パスワード、メール）

---

## スクリプトの特徴

### セキュリティ機能
- **自動セキュリティキー生成**: WordPress.orgから安全なキーを取得
- **wp-config.php保護**: パーミッション600で読み取り制限
- **ファイル編集無効化**: 管理画面からのファイル編集を防止
- **.htaccessセキュリティ設定**: wp-config.phpへのアクセス拒否、XMLRPCの保護
- **不要ファイル削除**: readme.html、license.txtの削除オプション

### ユーザビリティ
- **入力例表示**: すべての入力項目に具体例を表示
- **推奨デフォルト値**: yesが推奨の質問は [y] がデフォルト
- **色付き出力**: 成功(緑)、警告(黄)、エラー(赤)で視認性向上
- **自動パスワード生成**: 管理者パスワード未入力時は自動生成

### Webサーバー自動設定
- **Apache設定**: VirtualHost設定ファイル自動作成、mod_rewrite有効化
- **Nginx設定**: サーバーブロック設定ファイル自動作成
- **PHP-FPM対応**: Nginx使用時のPHPバージョン指定可能

---

## WP-CLIを使った手動コマンド

WP-CLIがインストールされている場合、個別のコマンドで設定できます。

### WP-CLIのインストール

```bash
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
```

### wp-config.phpの作成

```bash
wp config create \
  --dbname=wordpress_db \
  --dbuser=wordpress_user \
  --dbpass=your_password \
  --dbhost=localhost \
  --locale=ja \
  --allow-root
```

### WordPressのインストール

```bash
wp core install \
  --url=http://localhost \
  --title="My WordPress Site" \
  --admin_user=admin \
  --admin_password=your_admin_password \
  --admin_email=admin@example.com \
  --locale=ja \
  --allow-root
```

### 日本語パッケージのインストール

```bash
wp language core install ja --activate --allow-root
```

### プラグインのインストール

```bash
# プラグインの検索
wp plugin search security --allow-root

# プラグインのインストールと有効化
wp plugin install wordpress-seo --activate --allow-root
```

### テーマのインストール

```bash
# テーマの検索
wp theme search blog --allow-root

# テーマのインストールと有効化
wp theme install twentytwentyfour --activate --allow-root
```

---

## データベース操作コマンド

### MySQLコマンドラインでの操作

```bash
# MySQLにログイン
mysql -u root -p

# データベースの作成
CREATE DATABASE wordpress_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# ユーザーの作成と権限付与
CREATE USER 'wordpress_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### データベース接続のテスト

```bash
mysql -u wordpress_user -p wordpress_db
```

---

## パーミッション設定コマンド

```bash
# ディレクトリのパーミッション
find . -type d -exec chmod 755 {} \;

# ファイルのパーミッション
find . -type f -exec chmod 644 {} \;

# wp-config.phpのセキュリティ強化
chmod 600 wp-config.php

# uploadsディレクトリの作成と権限
mkdir -p wp-content/uploads
chmod 755 wp-content/uploads

# 所有者の変更（Webサーバーのユーザーに）
# Apache (Linux)
sudo chown -R www-data:www-data .

# Apache (macOS)
sudo chown -R _www:_www .

# Nginx
sudo chown -R nginx:nginx .
```

---

## トラブルシューティング

### データベース接続エラー

```bash
# データベース接続のテスト
wp db check --allow-root

# データベースの修復
wp db repair --allow-root

# データベースの最適化
wp db optimize --allow-root
```

### パーミッションエラー

```bash
# 現在のパーミッション確認
ls -la wp-config.php

# Webサーバーユーザーの確認
ps aux | grep -E 'apache|httpd|nginx'

# SELinuxの確認（Linux）
getenforce
```

### キャッシュのクリア

```bash
wp cache flush --allow-root
wp rewrite flush --allow-root
```

---

## セキュリティ強化コマンド

### 不要なファイルの削除

```bash
rm -f readme.html license.txt
```

### ファイルアクセス制限

```bash
# wp-config.phpへの直接アクセスを防ぐ（.htaccess）
cat >> .htaccess <<'EOF'

# wp-config.phpへのアクセス拒否
<files wp-config.php>
order allow,deny
deny from all
</files>
EOF
```

### SSL/TLS証明書の設定（Let's Encrypt）

```bash
# Certbotのインストール（Ubuntu/Debian）
sudo apt-get install certbot python3-certbot-apache

# 証明書の取得と自動設定
sudo certbot --apache -d yourdomain.com -d www.yourdomain.com
```

---

## バックアップコマンド

```bash
# データベースのバックアップ
wp db export backup-$(date +%Y%m%d).sql --allow-root

# ファイルのバックアップ
tar -czf wordpress-backup-$(date +%Y%m%d).tar.gz .

# wp-contentのみバックアップ
tar -czf wp-content-backup-$(date +%Y%m%d).tar.gz wp-content/
```

---

## Webサーバー設定

### Apache設定（自動生成される設定）

```apache
<VirtualHost *:80>
    ServerName yourdomain.com
    DocumentRoot /path/to/wordpress
    
    <Directory /path/to/wordpress>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/wordpress_error.log
    CustomLog ${APACHE_LOG_DIR}/wordpress_access.log combined
</VirtualHost>
```

**Apache設定の有効化:**
```bash
sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo systemctl restart apache2
```

### Nginx設定（自動生成される設定）

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    root /path/to/wordpress;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
```

**Nginx設定の有効化:**
```bash
sudo ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

---

## 環境変数を使った自動化

`.env`ファイルを作成して環境変数を設定できます。

```bash
# .envファイルの作成
cat > .env <<'EOF'
DB_NAME=wordpress_db
DB_USER=wordpress_user
DB_PASSWORD=your_password
DB_HOST=localhost
SITE_URL=http://localhost
SITE_TITLE=My WordPress Site
ADMIN_USER=admin
ADMIN_PASSWORD=admin_password
ADMIN_EMAIL=admin@example.com
EOF

# 環境変数の読み込み
source .env

# wp-config.phpの作成
wp config create \
  --dbname=$DB_NAME \
  --dbuser=$DB_USER \
  --dbpass=$DB_PASSWORD \
  --dbhost=$DB_HOST \
  --allow-root
```

---

## よくある質問（FAQ）

### Q: MySQLがインストールされていない場合は？
```bash
# macOS (Homebrew)
brew install mysql
brew services start mysql

# Ubuntu/Debian
sudo apt update
sudo apt install mysql-server

# CentOS/RHEL
sudo yum install mysql-server
sudo systemctl start mysqld
```

### Q: Apacheがインストールされていない場合は？
```bash
# macOS (Homebrew)
brew install httpd

# Ubuntu/Debian
sudo apt install apache2

# CentOS/RHEL
sudo yum install httpd
```

### Q: PHPがインストールされていない場合は？
```bash
# macOS (Homebrew)
brew install php

# Ubuntu/Debian
sudo apt install php php-mysql php-curl php-gd php-mbstring php-xml php-zip

# CentOS/RHEL
sudo yum install php php-mysqlnd php-curl php-gd php-mbstring php-xml php-zip
```

### Q: スクリプト実行中にエラーが出た場合は？
- **データベース接続エラー**: データベース情報が正しいか確認
- **パーミッションエラー**: `sudo` で実行するか、所有者を確認
- **WP-CLIエラー**: `wp --info` でWP-CLIの状態を確認

### Q: SSL/HTTPS対応は？
スクリプト実行後、Let's Encryptで証明書を取得:
```bash
# Apache
sudo certbot --apache -d yourdomain.com

# Nginx
sudo certbot --nginx -d yourdomain.com
```

---

## システム要件

### 必須
- **OS**: Linux、macOS、Unix系OS
- **Webサーバー**: Apache 2.4以上 または Nginx 1.18以上
- **PHP**: 7.4以上（推奨: 8.0以上）
- **MySQL**: 5.7以上 または MariaDB 10.3以上

### PHP拡張モジュール
- mysqli または pdo_mysql
- mbstring
- xml
- json
- curl
- zip
- gd または imagick

### 推奨環境
- メモリ: 最低512MB（推奨: 1GB以上）
- ディスク容量: 最低1GB（推奨: 5GB以上）

---

## トラブルシューティング Tips

### スクリプトが途中で止まる
```bash
# エラー出力を確認
bash -x ./install-wordpress.sh
```

### データベースに接続できない
```bash
# MySQL/MariaDBの起動確認
sudo systemctl status mysql
sudo systemctl status mariadb

# 接続テスト
mysql -u wordpress_user -p wordpress_db
```

### Webサーバーが起動しない
```bash
# 設定ファイルの文法チェック
# Apache
sudo apachectl configtest

# Nginx
sudo nginx -t

# ログの確認
sudo tail -f /var/log/apache2/error.log
sudo tail -f /var/log/nginx/error.log
```

---

## 参考リンク

- [WP-CLI 公式ドキュメント](https://wp-cli.org/)
- [WordPress 公式サイト（日本語）](https://ja.wordpress.org/)
- [WordPress Codex](https://wpdocs.osdn.jp/)
- [Let's Encrypt](https://letsencrypt.org/)
- [Apache ドキュメント](https://httpd.apache.org/docs/)
- [Nginx ドキュメント](https://nginx.org/en/docs/)
