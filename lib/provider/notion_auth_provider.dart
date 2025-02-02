import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final notionAuthProvider =
    StateNotifierProvider<NotionAuthNotifier, String?>((ref) {
  return NotionAuthNotifier();
});

class NotionAuthNotifier extends StateNotifier<String?> {
  NotionAuthNotifier() : super(null) {
    _loadToken();
  }

  final _storage = const FlutterSecureStorage();

  Future<void> _loadToken() async {
    final token = await _storage.read(key: 'notion_access_token');
    state = token;
  }

  Future<void> setToken(String token) async {
    state = token;
    await _storage.write(key: 'notion_access_token', value: token);
  }

  Future<void> clearToken() async {
    state = null;
    await _storage.delete(key: 'notion_access_token');
  }
}
