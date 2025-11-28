# Railway デプロイガイド

Railwayは、WordPress + MySQLを最も簡単にデプロイできるプラットフォームです。

## 特徴

- **MySQL対応**: ネイティブMySQLサポート
- **無料枠**: $5クレジット/月（約500時間）
- **簡単セットアップ**: GitHubリポジトリから自動デプロイ
- **ボリューム**: 永続ストレージ対応

## 前提条件

1. **Railwayアカウント**
   - [Railway](https://railway.app/)でアカウント作成（GitHubで簡単登録）

2. **GitHubリポジトリ**
   - このプロジェクトがGitHubにプッシュ済み

## デプロイ手順

### ステップ1: Reactテーマをビルド

```bash
cd wp-content/themes/minimal-react-theme
npm install
npm run build
cd ../../..
```

### ステップ2: GitHubにプッシュ

```bash
git add .
git commit -m "Prepare for Railway deployment"
git push origin main
```

### ステップ3: Railwayでプロジェクト作成

1. **[Railway Dashboard](https://railway.app/dashboard)にアクセス**

2. **「New Project」をクリック**

3. **「Deploy from GitHub repo」を選択**
   - GitHubアカウントを接続（初回のみ）
   - リポジトリ `wp-test` を選択

4. **「Add variables」をクリック**
   - まだ何も設定せずに次へ

### ステップ4: MySQLを追加

1. **プロジェクト画面で「+ New」をクリック**

2. **「Database」→「Add MySQL」を選択**

3. **自動的にMySQLがデプロイされる**
   - 接続情報が自動生成される
   - 環境変数が自動設定される：
     - `MYSQLHOST`
     - `MYSQLPORT`
     - `MYSQLUSER`
     - `MYSQLPASSWORD`
     - `MYSQLDATABASE`

### ステップ5: WordPress環境変数を設定

1. **WordPressサービスを選択**

2. **「Variables」タブをクリック**

3. **「RAW Editor」をクリックして以下を貼り付け**:

```bash
# MySQLの接続情報（自動入力される）
MYSQLHOST=${{MySQL.MYSQLHOST}}
MYSQLPORT=${{MySQL.MYSQLPORT}}
MYSQLUSER=${{MySQL.MYSQLUSER}}
MYSQLPASSWORD=${{MySQL.MYSQLPASSWORD}}
MYSQLDATABASE=${{MySQL.MYSQLDATABASE}}

# WordPress設定
WP_ENV=production
WP_DEBUG=false
```

4. **「Update Variables」をクリック**

### ステップ6: ボリュームを追加（アップロード用）

1. **WordPressサービスで「Settings」タブ**

2. **「Volumes」セクションで「+ New Volume」**

3. **設定**:
   - Mount Path: `/var/www/html/wp-content/uploads`
   - 「Add」をクリック

### ステップ7: デプロイ完了を待つ

1. **「Deployments」タブでビルドログを確認**

2. **デプロイ完了後、URLが生成される**
   - 例: `https://your-app.up.railway.app`

## WordPress初期設定

### 1. WordPressインストール

デプロイ完了後、以下のURLにアクセス:

```
https://your-app.up.railway.app/wp-admin/install.php
```

### 2. 基本情報を入力

- サイトタイトル
- ユーザー名
- パスワード
- メールアドレス

### 3. テーマを有効化

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

Railwayが自動的に再デプロイします。

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

## カスタムドメイン設定

### 1. ドメインを追加

1. WordPressサービスの「Settings」タブ
2. 「Domains」セクション
3. 「Custom Domain」に独自ドメインを入力

### 2. DNS設定

Railway が表示するCNAMEレコードをDNSに追加:

```
Type: CNAME
Name: www (またはサブドメイン)
Value: [Railwayが提供するドメイン]
```

### 3. SSL証明書

自動的に発行・更新されます（Let's Encrypt）

## トラブルシューティング

### データベース接続エラー

**症状:**
```
Error establishing a database connection
```

**解決策:**

1. **環境変数を確認**
   ```bash
   # Variables タブで以下が設定されているか確認
   MYSQLHOST
   MYSQLPORT
   MYSQLUSER
   MYSQLPASSWORD
   MYSQLDATABASE
   ```

2. **MySQL参照の確認**
   ```bash
   # RAW Editorで以下の形式になっているか確認
   MYSQLHOST=${{MySQL.MYSQLHOST}}
   ```

3. **MySQLサービスが起動しているか確認**
   - MySQL サービスのステータスを確認

### ログの確認方法

1. **WordPressサービスを選択**
2. **「Deployments」タブ**
3. **最新のデプロイをクリック**
4. **「View Logs」でログを確認**

### アップロードができない

**解決策:**

1. **ボリュームが正しくマウントされているか確認**
   - Settings → Volumes
   - Mount Path: `/var/www/html/wp-content/uploads`

2. **再デプロイ**
   - Settings → 「Redeploy」

### サイトが遅い

**解決策:**

1. **リージョンを確認**
   - Settings → Region
   - US West (推奨)

2. **キャッシュプラグインをインストール**
   - WP Super Cache
   - W3 Total Cache

## パフォーマンス最適化

### 1. キャッシュ設定

WordPressプラグインをインストール:
- **WP Super Cache** または **W3 Total Cache**

### 2. 画像最適化

プラグインをインストール:
- **Smush**
- **EWWW Image Optimizer**

### 3. CDN設定

- CloudflareをDNSレベルで設定
- WordPress設定でCDN URLを指定

## 無料枠の管理

### クレジット消費の確認

1. **Dashboard → Billing**
2. **使用状況を確認**

### コスト削減のヒント

1. **自動スリープ設定**
   - アクセスがない時に自動停止（デフォルトで有効）

2. **不要なサービスを削除**
   - 使っていないデータベースやサービスを削除

3. **リソース監視**
   - Metrics タブで CPU/メモリ使用量を確認

### 無料枠の上限

- **$5/月のクレジット**
- **約500実行時間** (常時起動で約20日)
- **1GBストレージ** (MySQL)

## セキュリティ設定

### 1. SSL/TLS

Railway が自動的に HTTPS を有効化（Let's Encrypt）

### 2. wp-config.php の保護

Dockerfileで自動的に設定済み（`chmod 600`）

### 3. セキュリティプラグイン

推奨プラグイン:
- **Wordfence Security**
- **iThemes Security**

## バックアップ

### データベース

1. **Railway Dashboard → MySQL サービス**
2. **「Backups」タブ**
3. **手動バックアップまたは自動バックアップを設定**

### ファイル

```bash
# wp-content/uploadsを定期的にバックアップ
# Volumeのデータはバックアップ推奨
```

## コスト見積もり

### 無料枠（Hobby Plan）
- **実行時間**: $5クレジット/月（約500時間）
- **MySQL**: 1GB ストレージ（無料枠内）
- **ボリューム**: 1GB（無料枠内）

### 有料プラン（Developer）
- **月額**: $5/月
- **実行時間**: $5クレジット + 追加$5クレジット
- **ストレージ**: 無制限
- **サポート**: 優先サポート

### 試算

**小規模サイト（月間1万PV）**
- 実行時間: 約$3-4/月
- 合計: 無料枠内

**中規模サイト（月間10万PV）**
- 実行時間: 約$10-15/月
- Developer プランで十分

## 監視とモニタリング

### メトリクス確認

1. **WordPressサービス → Metrics タブ**
2. **確認項目**:
   - CPU使用率
   - メモリ使用量
   - ネットワーク I/O

### アラート設定

1. **Settings → Notifications**
2. **Discord/Slack通知を設定**

## サポート

- **公式ドキュメント**: https://docs.railway.app/
- **Discord コミュニティ**: https://discord.gg/railway
- **Status Page**: https://status.railway.app/

## 参考リンク

- [Railway](https://railway.app/)
- [Railway Documentation](https://docs.railway.app/)
- [Railway Templates](https://railway.app/templates)

---

## クイックスタートまとめ

1. Reactテーマをビルド
2. GitHubにプッシュ
3. Railway で GitHub repo からデプロイ
4. MySQL を追加
5. 環境変数を設定（自動）
6. ボリュームを追加
7. https://your-app.up.railway.app/wp-admin/install.php にアクセス
8. テーマを有効化

**所要時間: 約10分**
