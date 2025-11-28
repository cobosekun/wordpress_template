# Render.comデプロイガイド

## 前提条件

1. **Render.comアカウント**
   - [Render.com](https://render.com/)でアカウント作成(GitHubアカウントで簡単登録)

2. **GitHubリポジトリ**
   - このプロジェクトをGitHubにプッシュ

## デプロイ手順

### 方法1: Blueprint経由(推奨・自動設定)

1. **リポジトリをプッシュ**
   ```bash
   git add .
   git commit -m "Add Render.com configuration"
   git push origin main
   ```

2. **Render.comでBlueprint経由でデプロイ**
   - [Render Dashboard](https://dashboard.render.com/)にアクセス
   - 「New」→「Blueprint」を選択
   - GitHubリポジトリを接続
   - `render.yaml`が自動検出される
   - 「Apply」をクリック

3. **デプロイ完了を待つ**
   - データベースとWebサービスが自動的に作成される
   - 5-10分程度でデプロイ完了

### 方法2: 手動設定

#### 1. Reactテーマをビルド

```bash
cd wp-content/themes/minimal-react-theme
npm install
npm run build
cd ../../..
```

#### 2. GitHubにプッシュ

```bash
git add .
git commit -m "Ready for Render deployment"
git push origin main
```

#### 3. データベースを作成

Render Dashboardで:
- 「New」→「PostgreSQL」を選択
- Name: `wordpress-db`
- Database: `wordpress`
- User: `wordpress`
- Region: Singapore (または最寄りのリージョン)
- Plan: Starter (無料)
- 「Create Database」をクリック

#### 4. Webサービスを作成

Render Dashboardで:
- 「New」→「Web Service」を選択
- GitHubリポジトリを接続
- 以下を設定:
  - **Name**: `wordpress-app`
  - **Region**: Singapore (DBと同じリージョン)
  - **Branch**: `main`
  - **Runtime**: Docker
  - **Dockerfile Path**: `./Dockerfile.render`
  - **Plan**: Starter (無料)

#### 5. 環境変数を設定

Environment Variables:
```
DATABASE_URL = [データベースのInternal Connection Stringをコピー]
WP_ENV = production
WP_DEBUG = false
```

#### 6. ディスクを追加

- 「Disks」セクションで「Add Disk」
- Name: `wordpress-uploads`
- Mount Path: `/var/www/html/wp-content/uploads`
- Size: 1 GB

#### 7. デプロイ

「Create Web Service」をクリック

## デプロイ後の設定

### 1. WordPressの初期設定

デプロイ完了後、提供されたURLにアクセス:
```
https://your-app.onrender.com/wp-admin/install.php
```

### 2. テーマを有効化

1. WordPress管理画面にログイン
2. 「外観」→「テーマ」
3. 「Minimal React Theme」を有効化

## 更新方法

### コードの更新

```bash
# 変更をコミット
git add .
git commit -m "Update WordPress"
git push origin main
```

Render.comが自動的に再デプロイします。

### テーマの更新

```bash
# Reactテーマをビルド
cd wp-content/themes/minimal-react-theme
npm run build
cd ../../..

# プッシュ
git add .
git commit -m "Update theme"
git push origin main
```

## トラブルシューティング

### ログの確認

Render Dashboard → サービスを選択 → 「Logs」タブ

### データベース接続エラー

1. Environment Variablesで`DATABASE_URL`が正しく設定されているか確認
2. データベースとWebサービスが同じリージョンにあるか確認
3. Internal Connection Stringを使用しているか確認(External URLではない)

### アップロードが保存されない

1. Diskが正しくマウントされているか確認
2. Mount Pathが`/var/www/html/wp-content/uploads`であることを確認

### デプロイが失敗する

```bash
# Dockerfileをローカルでテスト
docker build -f Dockerfile.render -t wordpress-test .
docker run -p 10000:10000 wordpress-test
```

## パフォーマンス最適化

### 1. CDNを有効化

Render.comの設定で:
- 「Settings」→「Custom Domains」でドメインを追加
- CloudflareやCloudinaryと統合

### 2. キャッシュプラグイン

WordPressプラグインをインストール:
- WP Super Cache
- W3 Total Cache

### 3. 画像最適化

プラグインをインストール:
- Smush
- EWWW Image Optimizer

## 無料プランの制限

### Starter Plan (無料)
- **Web Service**: 750時間/月まで無料
- **Database**: 90日後にデータ削除(有料プランへのアップグレード推奨)
- **Disk**: 1GBまで無料
- **帯域幅**: 100GB/月

### アイドル対策

無料プランではアクセスがないと15分後にスリープします:
- 外部監視サービス(UptimeRobot等)でpingを送信
- 有料プランにアップグレード($7/月〜)

## カスタムドメイン

1. Render Dashboard → サービスを選択
2. 「Settings」→「Custom Domains」
3. ドメインを追加
4. DNSレコードを設定(表示される指示に従う)
5. SSL証明書は自動発行

## バックアップ

### データベース

```bash
# Render Dashboardから手動バックアップ
# または自動バックアップを設定(有料プラン)
```

### ファイル

```bash
# wp-content/uploadsの定期バックアップを推奨
# Render DiskはGitには含まれない
```

## セキュリティ

### SSL/TLS

Render.comが自動的にLet's Encryptの証明書を発行・更新

### wp-config.phpの保護

Dockerfileで自動的に設定済み(`chmod 600`)

### セキュリティプラグイン

推奨プラグイン:
- Wordfence Security
- iThemes Security

## コスト見積もり

### 無料構成
- Web Service (Starter): $0/月 (750時間まで)
- PostgreSQL (Starter): $0/月 (90日間)
- Disk (1GB): $0/月

### 推奨構成(本番環境)
- Web Service (Starter): $7/月
- PostgreSQL (Starter): $7/月
- Disk (10GB): 無料枠内

**合計: 約$14/月**

## サポート

- [Render.com Documentation](https://render.com/docs)
- [Render Community](https://community.render.com/)
- [WordPress on Render](https://render.com/docs/deploy-wordpress)

## 参考リンク

- [Render.com](https://render.com/)
- [Render Docs](https://render.com/docs)
- [Render Status](https://status.render.com/)
