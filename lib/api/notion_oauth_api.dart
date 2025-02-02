import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NotionOAuthApi {
  // 認可コード(code)をアクセストークンに変換するメソッド
  static Future<String?> exchangeCodeForToken(String code) async {
    final url = Uri.parse("https://api.notion.com/v1/oauth/token");
    // dotenvから値を取得
    final clientId = dotenv.env['OAUTH_CLIENT_ID'] ?? '';
    final clientSecret = dotenv.env['OAUTH_CLIENT_SECRET'] ?? '';
    final redirectUri = dotenv.env['NOTION_REDIRECT_URI'] ?? '';

    final authCredentials = '$clientId:$clientSecret';
    final encodedCredentials = base64Encode(utf8.encode(authCredentials));

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic $encodedCredentials',
      'Notion-Version': '2022-06-28',
    };

    final body = jsonEncode({
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': redirectUri,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      print("アクセストークン取得エラー: ${response.body}");
      return null;
    }
  }
}
