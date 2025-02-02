import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider/notion_auth_provider.dart';
import 'widget/notion_login_webview_widget.dart';

Future<void> main() async {
  // Flutter の初期化前に dotenv をロード
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: NotionTemplateConnectorApp()));
}

class NotionTemplateConnectorApp extends ConsumerWidget {
  const NotionTemplateConnectorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(notionAuthProvider);
    return MaterialApp(
      title: 'Notion Template Connector',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Notion Template Connector'),
        ),
        body: Center(
          child: token == null
              ? Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const NotionLoginWebviewWidget()));
                    },
                    child: const Text('Notionと連携する'),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Notionと連携済み'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: () {
                          ref.read(notionAuthProvider.notifier).clearToken();
                        },
                        child: const Text('連携解除')),
                  ],
                ),
        ),
      ),
    );
  }
}
