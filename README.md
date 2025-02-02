# notion_template_connector

Notion Template Connector は、Flutter アプリからあなたの Notion アカウントに対して、開発者提供のテンプレート連携（OAuth 認証）を実装するサンプルプロジェクトです。

## 特徴
- Notion の OAuth 認証を利用してアクセストークンを取得
- アプリ内 WebView を使った認証フローの実装
- GitHub Pages 上のリダイレクトページ経由で認可コード（code）を受信
- Secure Storage と Riverpod による認証状態の管理

## ディレクトリ構成
```plaintext
notion_template_connector/
├── .env                      # 環境変数ファイル
├── README.md                 # プロジェクト説明ファイル
├── pubspec.yaml              # Flutter設定ファイル
├── lib/
│   ├── main.dart             # エントリーポイント
│   ├── api/
│   │   └── notion_oauth_api.dart   # NotionのOAuth関連APIクラス
│   ├── env/
│   │   ├── env.dart          # 環境変数読み込み定義
│   │   └── env.g.dart        # 自動生成ファイル（build_runnerで生成）
│   ├── provider/
│   │   └── notion_auth_provider.dart   # 認証状態を管理するプロバイダ
│   └── widget/
│       └── notion_login_webview_widget.dart   # OAuth認証用WebViewウィジェット
└── docs/
    └── redirects/
        ├── index.html        # Notionからのリダイレクト用HTML
        └── fallback.html     # エラー発生時のHTML

```


## 開発手順

1. **Notion Integration の作成**
    - Notion Developer Dashboard でパブリックインテグレーションを作成し、以下の情報を取得します。
        - OAuth クライアントID
        - OAuth クライアントシークレット
        - 認証URL
        - リダイレクト URI
    - 取得した値はサーバー側で安全に管理し、ここでは環境変数（.env）に設定します。

2. **GitHub Pages の設定**
    - `docs/redirects/` 以下にある `index.html` と `fallback.html` を GitHub Pages でホスティングし、Notion のリダイレクト URI として登録します。

3. **Flutter プロジェクトのセットアップ**
    - 本プロジェクトをクローン後、プロジェクトルートで `flutter pub get` を実行して依存関係をインストールします。
    - [envied](https://pub.dev/packages/envied) を使って環境変数の自動生成（`flutter pub run build_runner build`）を行います。

4. **アプリの動作確認**
    - アプリ起動時、未連携状態なら「Notionと連携する」ボタンが表示されます。
    - ボタン押下で内蔵WebViewが起動し、Notion の OAuth 認証画面へ遷移します。
    - 認証完了後、GitHub Pages のリダイレクトページが認可コード（code）を取得し、JavaScript によりカスタム URL スキーム（例：`notionsample://oauth/callback?code=...`）へリダイレクトします。
    - Flutter アプリ側でこの深いリンク（deeplink）を受信し、バックエンド（ここでは簡易的にアプリ内の API クラス）を通じて Notion のアクセストークン発行を行い、secure_storage に保存します。
    - 連携完了後は連携済み状態が表示され、必要に応じて「連携解除」ボタンでトークンを削除できます。

## 使用技術
- Flutter
- flutter_inappwebview
- flutter_secure_storage
- riverpod
- http
- envied
- uni_links

## ライセンス
本プロジェクトは MIT ライセンスのもと公開されています。
# notion_template_connector
