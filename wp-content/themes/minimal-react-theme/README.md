# Minimal React Theme セットアップガイド

## 概要
Apple風ミニマルデザインのWordPressテーマ（React + Framer Motion）

## セットアップ手順

### 1. 依存関係のインストール

```bash
cd wordpress/wp-content/themes/minimal-react-theme
npm install
```

### 2. 開発サーバーの起動（開発時）

```bash
npm run dev
```

開発サーバーは `http://localhost:5173` で起動します。

### 3. 本番用ビルド

```bash
npm run build
```

ビルドされたファイルは `dist/` ディレクトリに出力されます。

### 4. WordPressでテーマを有効化

1. WordPress管理画面にログイン
2. 「外観」→「テーマ」に移動
3. "Minimal React Theme" を有効化

## ディレクトリ構造

```
minimal-react-theme/
├── src/
│   ├── App.jsx          # メインReactコンポーネント
│   ├── main.jsx         # エントリーポイント
│   └── index.css        # グローバルスタイル（Tailwind含む）
├── dist/                # ビルド出力先（本番用）
├── functions.php        # WordPressテーマ関数
├── front-page.php       # フロントページテンプレート
├── index.php            # メインテンプレート
├── style.css            # テーマスタイルシート（必須）
├── package.json         # Node.js依存関係
├── vite.config.js       # Viteビルド設定
├── tailwind.config.js   # Tailwind CSS設定
└── postcss.config.js    # PostCSS設定
```

## 使用技術

- **React 18**: UIコンポーネント
- **Framer Motion 11**: アニメーション
- **Tailwind CSS 3**: スタイリング
- **Vite 5**: ビルドツール

## 開発ワークフロー

### 開発モード
開発時は `npm run dev` を実行すると、Viteの開発サーバーがホットリロードで起動します。
`functions.php` が開発サーバーのスクリプトを自動的に読み込みます。

### 本番モード
本番環境では、`npm run build` でビルドしたファイルを使用します。
`functions.php` が `dist/manifest.json` を参照して、ビルド済みのアセットを読み込みます。

## 主な機能

- ✨ カスタムカーソル（デスクトップのみ）
- 📊 スクロールプログレスバー
- 🎬 ローディングアニメーション
- 📝 文字単位アニメーション
- 🎨 パララックス効果
- 🎯 3D傾きカード
- 🧲 マグネットボタン
- 📈 カウントアップ統計
- 💬 テスティモニアル
- 📱 完全レスポンシブ

## カスタマイズ

### テキストの変更
`src/App.jsx` 内の各セクションのテキストを編集してください。

### スタイルの変更
`tailwind.config.js` でTailwindのテーマをカスタマイズできます。

### 画像の追加
`ImagePlaceholder` コンポーネントを実際の画像タグに置き換えてください。

## トラブルシューティング

### ビルドエラーが出る場合
```bash
rm -rf node_modules package-lock.json
npm install
```

### WordPress画面が真っ白な場合
1. `npm run build` が正常に完了しているか確認
2. `dist/` ディレクトリにファイルが生成されているか確認
3. ブラウザのコンソールでエラーを確認

### カーソルが表示されない（モバイル）
モバイルデバイスでは意図的にカスタムカーソルを無効化しています。

## ライセンス

GPL v2 or later
