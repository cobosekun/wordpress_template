#!/bin/bash

# ========================================
# Minimal React Theme セットアップスクリプト
# ========================================

THEME_DIR="wordpress/wp-content/themes/minimal-react-theme"
THEME_NAME="Minimal React Theme"

echo "========================================="
echo "  ${THEME_NAME} セットアップ"
echo "========================================="
echo ""

# テーマディレクトリに移動
if [ ! -d "$THEME_DIR" ]; then
    echo "エラー: テーマディレクトリが見つかりません: $THEME_DIR"
    exit 1
fi

cd "$THEME_DIR"

echo "📦 依存関係をインストール中..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ npm installに失敗しました"
    exit 1
fi

echo "✅ 依存関係のインストール完了"
echo ""

echo "🔨 Reactアプリをビルド中..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ ビルドに失敗しました"
    exit 1
fi

echo "✅ ビルド完了"
echo ""

echo "========================================="
echo "  セットアップ完了!"
echo "========================================="
echo ""
echo "次のステップ:"
echo "1. WordPress管理画面にアクセス (http://localhost:8000/wp-admin/)"
echo "2. 「外観」→「テーマ」に移動"
echo "3. 「${THEME_NAME}」を有効化"
echo ""
echo "開発モード（ホットリロード）:"
echo "  cd $THEME_DIR && npm run dev"
echo ""
echo "本番ビルド:"
echo "  cd $THEME_DIR && npm run build"
echo ""
