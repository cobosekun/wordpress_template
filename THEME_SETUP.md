# WordPress React テーマセットアップ完了 🎉

## 作成されたもの

Apple風ミニマルデザインのWordPressテーマ「**Minimal React Theme**」が作成されました。

## セットアップ状況

✅ Reactアプリケーション作成完了  
✅ 依存関係インストール完了  
✅ 本番ビルド完了  
✅ WordPressテーマファイル作成完了  

## 📁 テーマの場所

```
wordpress/wp-content/themes/minimal-react-theme/
```

## 🚀 次のステップ

### 1. WordPressでテーマを有効化

1. ブラウザで http://localhost:8000/wp-admin/ にアクセス
2. ログイン（ユーザー名とパスワードはインストール時に設定したもの）
3. 左メニューの「外観」→「テーマ」をクリック
4. 「Minimal React Theme」を見つけて「有効化」ボタンをクリック

### 2. トップページを確認

http://localhost:8000/ にアクセスすると、Apple風のミニマルデザインのページが表示されます。

## 🎨 テーマの機能

- ✨ **カスタムカーソル** - マウスを追従する美しいカーソル（デスクトップのみ）
- 📊 **スクロールプログレスバー** - ページ上部にスクロール進捗を表示
- 🎬 **ローディングアニメーション** - ページ読み込み時のエレガントなアニメーション
- 📝 **文字単位アニメーション** - テキストが1文字ずつ現れる演出
- 🎨 **パララックス効果** - スクロールに応じた立体的な動き
- 🎯 **3D傾きカード** - マウスホバーで傾く3Dカード
- 🧲 **マグネットボタン** - マウスに引き寄せられるようなボタン
- 📈 **カウントアップ統計** - 数字が動的にカウントアップ
- 💬 **テスティモニアル** - お客様の声セクション
- 📱 **完全レスポンシブ** - PC、タブレット、スマホ対応

## 🛠️ 開発モード

テーマをカスタマイズする場合は、開発モードを使用します:

```bash
cd wordpress/wp-content/themes/minimal-react-theme
npm run dev
```

これにより、コードの変更が即座にブラウザに反映されます（ホットリロード）。

## 📝 カスタマイズ方法

### テキストの変更

`src/App.jsx` を編集してテキストを変更できます:

```javascript
// 例: ヒーローセクションのテキスト変更
<CharacterAnimation
  text="あなたのメッセージ"  // ← ここを変更
  className="text-5xl md:text-7xl lg:text-8xl font-semibold tracking-tight mb-6"
/>
```

### 色の変更

`tailwind.config.js` でカラーテーマをカスタマイズ:

```javascript
theme: {
  extend: {
    colors: {
      primary: '#your-color',
      // ...
    }
  }
}
```

### 画像の追加

`ImagePlaceholder` コンポーネントを実際の画像に置き換え:

```javascript
// Before
<ImagePlaceholder text="Hero Image" className="aspect-video w-full" />

// After
<img src="/path/to/image.jpg" alt="Hero" className="aspect-video w-full rounded-3xl" />
```

## 🔄 変更を反映する

開発モードで作業した後、本番用にビルド:

```bash
cd wordpress/wp-content/themes/minimal-react-theme
npm run build
```

## 📚 使用技術

- **React 18** - UIコンポーネント
- **Framer Motion 11** - アニメーションライブラリ
- **Tailwind CSS 3** - ユーティリティファーストCSS
- **Vite 5** - 高速ビルドツール
- **WordPress** - CMSプラットフォーム

## 🎯 パフォーマンス

- ビルドサイズ: ~281KB (gzip圧縮時: ~92KB)
- CSS: ~15KB (gzip圧縮時: ~4KB)
- ローディング時間: < 1秒（ローカル環境）

## ⚠️ トラブルシューティング

### テーマが表示されない場合

1. ビルドが完了しているか確認:
   ```bash
   ls -la wordpress/wp-content/themes/minimal-react-theme/dist/
   ```

2. dist/フォルダが空の場合、再ビルド:
   ```bash
   cd wordpress/wp-content/themes/minimal-react-theme
   npm run build
   ```

3. ブラウザのキャッシュをクリア（Cmd + Shift + R）

### npm installでエラーが出る場合

```bash
cd wordpress/wp-content/themes/minimal-react-theme
rm -rf node_modules package-lock.json
npm install
```

### カスタムカーソルが表示されない

モバイルデバイスやタブレットでは、カスタムカーソルは意図的に無効化されています（タッチ操作には不要なため）。

## 📞 サポート

問題が発生した場合は、以下を確認してください:

1. Node.jsバージョン: v16以上推奨
2. npmバージョン: v8以上推奨
3. ブラウザのコンソールでJavaScriptエラーをチェック
4. WordPress Debug Mode: `wp-config.php` で `WP_DEBUG` を `true` に設定

## 🎉 完了!

テーマのセットアップは完了です。素晴らしいWebサイトを作成してください!

---

**制作**: WordPress + React + Framer Motion  
**ライセンス**: GPL v2 or later
