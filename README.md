# WordPress Template

WordPressのローカル開発環境テンプレートです。自動インストールスクリプトでWordPressをセットアップし、Docker Composeでローカル開発環境を展開します。

## 概要

このリポジトリは、以下の手順でWordPressのローカル開発環境を構築します：

1. `install-wordpress.sh` スクリプトでWordPressをセットアップ
2. `docker-compose.local.yml` でDocker開発環境を展開

## 必要なもの

- Docker & Docker Compose
- Bash（スクリプト実行用）

## セットアップ方法

### 1. リポジトリをクローン

```bash
git clone https://github.com/cobosekun/wordpress_template.git
cd wordpress_template
```

### 2. WordPressの自動セットアップ

インストールスクリプトを実行してWordPressをダウンロード・設定します。

```bash
chmod +x install-wordpress.sh
./install-wordpress.sh
```

#### スクリプトの主な動作

スクリプトは以下を自動で行います：

- ✅ WordPress最新版のダウンロード
- ✅ 必要な依存関係のチェック（PHP、MySQL、WP-CLI）
- ✅ データベース設定の入力プロンプト
- ✅ `wp-config.php` の生成
- ✅ WordPressサイト情報の設定
- ✅ ファイルパーミッションの設定
- ✅ セキュリティ設定の適用

#### スクリプトで入力する情報

**データベース設定**
- データベース名: お好みの名前（例: `wordpress_db`）
- ユーザー名: お好みのユーザー名（例: `wordpress_user`）
- パスワード: 安全なパスワードを入力
- ホスト: `localhost` (Enter)
- テーブル接頭辞: `wp_` (Enter)

**データベース作成**
- 「データベースを作成しますか？」→ `y` (ローカルMySQLにデータベースを作成)

**WordPressサイト設定**
- サイトURL: `http://localhost:8000` (Enter)
- サイトタイトル: お好みのタイトル
- 管理者ユーザー名: お好みのユーザー名（例: `admin`）
- 管理者パスワード: お好みのパスワード
- 管理者メールアドレス: お好みのメールアドレス

**WP-CLIインストール**
- 「WP-CLIをインストールしますか？」→ `y` (推奨)
- WP-CLIでのインストールが完了します

**Webサーバー選択**
- 「使用するWebサーバーを選択してください」→ `4` (スキップを選択、Docker環境で実行するため)

### 3. Docker Composeでローカル環境を起動

WordPressファイルがセットアップされたら、Docker環境を起動します。

```bash
docker compose -f docker-compose.local.yml up --build
```

初回起動時は、イメージのダウンロードとビルドに数分かかる場合があります。

以下のメッセージが表示されたら起動完了です：

```
wordpress  | AH00558: apache2: Could not reliably determine the server's fully qualified domain name
wordpress  | [Date Time] Apache/2.4.xx (Debian) PHP/8.2.x configured -- resuming normal operations
```

### 4. WordPressにアクセス

ブラウザで http://localhost:8000 にアクセスしてください。

スクリプトで既にWordPressのインストールが完了しているため、すぐにサイトが表示されます。

- **サイトURL**: http://localhost:8000
- **管理画面**: http://localhost:8000/wp-admin/
- **ログイン情報**: スクリプトで設定したユーザー名とパスワード

### 5. 開発環境の停止

```bash
# コンテナを停止（データは保持）
docker compose -f docker-compose.local.yml down

# コンテナを停止してデータも削除
docker compose -f docker-compose.local.yml down -v
```

### 6. 再起動

次回以降は、以下のコマンドで起動できます：

```bash
docker compose -f docker-compose.local.yml up
```

`--build` オプションは初回のみ必要です。

## ファイル構成

- `Dockerfile`: WordPressコンテナの定義
- `docker-compose.local.yml`: ローカル開発環境用のDocker Compose設定
- `.dockerignore`: Dockerビルド時の除外ファイル設定

## カスタムテーマの開発

カスタムテーマは `wp-content/themes/` ディレクトリに配置します。

### 1. テーマディレクトリの作成

```bash
mkdir -p wp-content/themes/your-theme
```

### 2. テーマファイルの配置

`wp-content/themes/your-theme/` にテーマファイルを追加します。

最低限必要なファイル：
- `style.css` (テーマ情報を含む)
- `index.php` (メインテンプレート)

### 3. Docker環境での反映

`docker-compose.local.yml` でテーマディレクトリが自動的にマウントされます：

```yaml
volumes:
  - ./wp-content/themes/your-theme:/var/www/html/wp-content/themes/your-theme
```

テーマファイルを変更した後は、ブラウザをリロードするだけで反映されます。

### 4. テーマの有効化

WordPress管理画面 → 外観 → テーマ から、作成したテーマを有効化してください。

## プラグインの追加

### 1. プラグインディレクトリに配置

```bash
cd wp-content/plugins
# プラグインファイルをここに配置
```

### 2. WordPress管理画面から有効化

管理画面 → プラグイン → インストール済みプラグイン から有効化してください。

### 3. volume設定（必要に応じて）

特定のプラグインをボリュームマウントしたい場合は、`docker-compose.local.yml` に追加：

```yaml
volumes:
  - ./wp-content/plugins/your-plugin:/var/www/html/wp-content/plugins/your-plugin
```

## データベースへの接続

ローカルMySQLに接続する方法です。

### MySQLクライアントから接続

```bash
mysql -h localhost -u [ユーザー名] -p [データベース名]
```

スクリプトで設定した情報を使用してください。

### データベース情報

- **ホスト**: `localhost`
- **ポート**: `3306`
- **データベース名**: スクリプトで設定した名前
- **ユーザー名**: スクリプトで設定したユーザー名
- **パスワード**: スクリプトで設定したパスワード

### Docker環境からローカルMySQLへの接続

Docker ComposeはローカルのMySQLに接続するため、`docker-compose.local.yml`内で環境変数が適切に設定されています。

## トラブルシューティング

### ポート8000が既に使用されている

他のアプリケーションがポート8000を使用している場合、`docker-compose.local.yml` のポート番号を変更してください：

```yaml
ports:
  - "8080:80"  # 8000から8080に変更
```

変更後、http://localhost:8080 でアクセスできます。

### データベース接続エラー

ローカルMySQLが起動しているか確認してください：

```bash
# macOS (Homebrew)
brew services list | grep mysql

# MySQLが起動していない場合
brew services start mysql
```

Dockerコンテナが正しく起動しているか確認：

```bash
docker compose -f docker-compose.local.yml ps
```

`wp-config.php`のデータベース設定が正しいか確認してください。

### パーミッションエラー

wp-contentディレクトリに書き込み権限がない場合：

```bash
chmod -R 755 wp-content
```

### ファイルのアップロードができない

uploads ディレクトリの権限を確認：

```bash
chmod -R 755 wp-content/uploads
```

### コンテナが起動しない

既存のコンテナとボリュームを削除して再起動：

```bash
docker compose -f docker-compose.local.yml down -v
docker compose -f docker-compose.local.yml up --build
```

### WordPress初期化画面が何度も表示される

ブラウザのキャッシュをクリアするか、シークレットモードで開いてください。

## ファイル構成

```
wordpress_template/
├── Dockerfile                    # WordPressコンテナの定義
├── docker-compose.local.yml      # ローカル開発環境用のDocker Compose設定
├── install-wordpress.sh          # WordPress自動セットアップスクリプト
├── .dockerignore                 # Dockerビルド時の除外ファイル設定
├── README.md                     # このファイル
└── wp-content/                   # WordPressコンテンツディレクトリ
    ├── themes/                   # カスタムテーマを配置
    ├── plugins/                  # カスタムプラグインを配置
    └── uploads/                  # アップロードファイル
```

## よくある質問

**Q: install-wordpress.sh の実行は必須ですか？**

A: はい。スクリプトがWordPressファイルをダウンロードし、必要な設定ファイルを生成します。これがないとDocker環境を起動してもWordPressが動作しません。

**Q: スクリプトでデータベース作成を「y」にするのはなぜですか？**

A: このテンプレートはローカルのMySQLを使用します。スクリプトがローカルMySQLにデータベースとユーザーを作成し、Docker環境のWordPressがそのデータベースに接続します。

**Q: WordPressのインストールウィザードが表示されないのですが？**

A: 以下を確認してください：
- ローカルMySQLが起動しているか（`brew services list | grep mysql`）
- Docker環境が正しく起動しているか（`docker compose -f docker-compose.local.yml ps`）
- ブラウザで正しいURL（http://localhost:8000）にアクセスしているか
- スクリプトでWordPressのインストールが完了している場合、ウィザードは表示されず直接サイトが表示されます

**Q: 既存のWordPressサイトをインポートできますか？**

A: はい。以下の手順でインポートできます：
1. `wp-content/themes`、`wp-content/plugins`、`wp-content/uploads` ディレクトリの内容をコピー
2. データベースのSQLダンプをインポート：
   ```bash
   mysql -u [ユーザー名] -p [データベース名] < backup.sql
   ```

**Q: 本番環境へのデプロイはどうすればいいですか？**

A: このテンプレートは開発環境用です。本番環境にデプロイする場合は、以下を推奨します：
- Railway、AWS、Herokuなどのクラウドサービスを利用
- セキュリティ設定の強化（SSL/TLS、ファイアウォール等）
- 定期的なバックアップの設定
- パフォーマンス最適化（キャッシュプラグイン等）

**Q: テーマやプラグインの変更がすぐに反映されません**

A: ブラウザのキャッシュをクリアするか、スーパーリロード（Cmd+Shift+R / Ctrl+Shift+R）を試してください。

## ライセンス

このテンプレートはMITライセンスの下で公開されています。
