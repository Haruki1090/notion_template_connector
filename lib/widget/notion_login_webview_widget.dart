import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/notion_oauth_api.dart';
import '../env/env.dart';
import '../provider/notion_auth_provider.dart';

class NotionLoginWebviewWidget extends ConsumerStatefulWidget {
  const NotionLoginWebviewWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<NotionLoginWebviewWidget> createState() =>
      _NotionLoginWebviewWidgetState();
}

class _NotionLoginWebviewWidgetState
    extends ConsumerState<NotionLoginWebviewWidget> {
  InAppWebViewController? _webViewController;
  // カスタムURLスキーム（例: "notionsample"）
  final String customScheme = "notionsample";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notion Login')),
      body: InAppWebView(
        initialUrlRequest:
            URLRequest(url: WebUri(Uri.parse(Env.authUrl).toString())),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useShouldOverrideUrlLoading: true,
            javaScriptEnabled: true,
            // 最新のブラウザを模倣するUser Agentに更新
            userAgent: Platform.isIOS
                ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1'
                : 'Mozilla/5.0 (Linux; Android 12; Pixel 5 Build/SQ3A.220705.003) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.5112.97 Mobile Safari/537.36',
          ),
          android: AndroidInAppWebViewOptions(
            disableDefaultErrorPage: true,
          ),
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final uri = navigationAction.request.url;
          if (uri != null && uri.scheme == customScheme) {
            // カスタムURLスキームによるdeeplink受信
            final code = uri.queryParameters['code'];
            if (code != null) {
              // 認可コードをアクセストークンに交換する
              final token = await NotionOAuthApi.exchangeCodeForToken(code);
              if (token != null) {
                ref.read(notionAuthProvider.notifier).setToken(token);
                // 認証完了後、WebView画面を閉じる
                Navigator.of(context).pop();
              }
            }
            return NavigationActionPolicy.CANCEL;
          }
          return NavigationActionPolicy.ALLOW;
        },
      ),
    );
  }
}
