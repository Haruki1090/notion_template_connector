import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/notion_oauth_api.dart';
import '../env/env.dart';
import '../provider/notion_auth_provider.dart';

class NotionLoginWebviewWidget extends ConsumerStatefulWidget {
  const NotionLoginWebviewWidget({super.key});

  @override
  ConsumerState<NotionLoginWebviewWidget> createState() =>
      _NotionLoginWebviewWidgetState();
}

class _NotionLoginWebviewWidgetState
    extends ConsumerState<NotionLoginWebviewWidget> {
  // カスタムURLスキーム（例: "notionsample"）
  final String customScheme = "notionsample";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notion Login')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri((Env.authUrl).toString())),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useShouldOverrideUrlLoading: true,
            javaScriptEnabled: true,
            userAgent: Platform.isIOS
                ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_1_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.1 Mobile/15E148 Safari/604.1'
                : 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36',
          ),
          android: AndroidInAppWebViewOptions(
            disableDefaultErrorPage: true,
          ),
        ),
        onWebViewCreated: (controller) {},
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final uri = navigationAction.request.url;
          if (uri != null && uri.scheme == customScheme) {
            // カスタムURLスキームによる deeplink 受信
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
