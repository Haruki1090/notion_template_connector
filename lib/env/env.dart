import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied()
class Env {
  @EnviedField(varName: 'OAUTH_CLIENT_ID')
  static final String clientId = _Env.clientId;

  @EnviedField(varName: 'OAUTH_CLIENT_SECRET')
  static final String clientSecret = _Env.clientSecret;

  @EnviedField(varName: 'NOTION_AUTH_URL')
  static final String authUrl = _Env.authUrl;

  @EnviedField(varName: 'NOTION_REDIRECT_URI')
  static final String redirectUri = _Env.redirectUri;
}
