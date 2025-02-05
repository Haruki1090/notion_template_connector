import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/notion_oauth_api.dart';
import '../provider/notion_auth_provider.dart';

class NotionLoginWebviewWidget extends ConsumerStatefulWidget {
  const NotionLoginWebviewWidget({super.key});

  @override
  ConsumerState<NotionLoginWebviewWidget> createState() =>
      _NotionLoginWebviewWidgetState();
}

class _NotionLoginWebviewWidgetState
    extends ConsumerState<NotionLoginWebviewWidget> {
  // カスタムURLスキーム
  final String customScheme = "notionsample";

  @override
  Widget build(BuildContext context) {
    // dotenvから認証URLを取得
    final authUrl = dotenv.env['NOTION_AUTH_URL'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Notion Login')),
      body: InAppWebView(
        // 初期URLは.envから取得した認証URL
        initialUrlRequest:
            URLRequest(url: WebUri(Uri.parse(authUrl).toString())),
        // WebViewのオプション設定
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useShouldOverrideUrlLoading: true, // URL遷移時に独自処理を行う
            javaScriptEnabled: true, // JavaScriptを有効化
            // 最新のブラウザを模倣するUser Agentに更新
            userAgent: Platform.isIOS
                ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1'
                : 'Mozilla/5.0 (Linux; Android 12; Pixel 5 Build/SQ3A.220705.003) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.5112.97 Mobile Safari/537.36',
          ),
          // Android固有のWebViewのオプション設定（エラーページを無効化）
          android: AndroidInAppWebViewOptions(
            disableDefaultErrorPage: true,
          ),
        ),
        onWebViewCreated: (controller) {},
        // URL遷移を監視し、特定のURLに対して独自の処理を行うためのコールバック
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          // 遷移先のURLを取得
          final uri = navigationAction.request.url;
          // カスタムスキームの場合のみ独自処理を行う
          if (uri != null && uri.scheme == customScheme) {
            // URLパラメータから "code" および "duplicated_template_id" を抽出
            final code = uri.queryParameters['code'];
            final duplicatedTemplateId =
                uri.queryParameters['duplicated_template_id'];
            if (code != null) {
              // 通常の認証コードがある場合、アクセストークンに交換
              final token = await NotionOAuthApi.exchangeCodeForToken(code);
              if (token != null) {
                // アクセストークンをRiverpodのProviderに保存
                ref.read(notionAuthProvider.notifier).setToken(token);
                // 認証成功後、画面を閉じる
                Navigator.of(context).pop();
              }
            } else if (duplicatedTemplateId != null) {
              // テンプレート複製が成功した場合、必要に応じてduplicated_template_idを利用する
              // ここでは、認証成功としてフラグをセットする例を示す
              // ※本来は、テンプレート複製後にNotion側で発行されるアクセストークンを取得する必要がある場合もありますが、
              // ここではシンプルな例として連携完了とみなします。
              ref
                  .read(notionAuthProvider.notifier)
                  .setToken('template_duplicated:$duplicatedTemplateId');
              Navigator.of(context).pop();
            } else {
              // 両方のパラメータが存在しない場合、エラー処理へ
              // 必要に応じてエラーメッセージを表示するなどの対応を検討
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('認証コードの取得に失敗しました'),
              ));
            }
            // カスタムURLスキームの場合は、遷移をキャンセル
            return NavigationActionPolicy.CANCEL;
          }
          // カスタムスキーム以外の場合は、遷移を許可
          return NavigationActionPolicy.ALLOW;
        },
      ),
    );
  }
}
