import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// notionAuthProviderは、NotionAuthNotifierの状態を管理するStateNotifierProvider
final notionAuthProvider =
    StateNotifierProvider<NotionAuthNotifier, String?>((ref) {
  return NotionAuthNotifier();
});

// NotionAuthNotifierは、Notionの認証トークンを管理するStateNotifier
class NotionAuthNotifier extends StateNotifier<String?> {
  NotionAuthNotifier() : super(null) {
    _loadToken(); // 初期化時にトークンを読み込む
  }

  // FlutterSecureStorageを使用してトークンを安全に保存
  final _storage = const FlutterSecureStorage();

  // 非同期でトークンを読み込むメソッド
  Future<void> _loadToken() async {
    final token = await _storage.read(key: 'notion_access_token');
    state = token; // 読み込んだトークンを状態に設定
  }

  // 非同期でトークンを保存するメソッド
  Future<void> setToken(String token) async {
    state = token; // 状態を更新
    await _storage.write(key: 'notion_access_token', value: token); // トークンを保存
  }

  // 非同期でトークンを削除するメソッド
  Future<void> clearToken() async {
    state = null; // 状態をクリア
    await _storage.delete(key: 'notion_access_token'); // トークンを削除
  }
}
