import 'package:googleapis_auth/auth_io.dart';
import 'package:target_ace/core/config/service_account_key.dart';

class AccessTokenGenerator {
  static Future<String> generateAccessToken() async {
    final scopes = [
      "https://www.googleapis.com/auth/firebase.messaging",
    ];
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(serviceAccountKey),
      scopes,
    );
    final accessToken = client.credentials.accessToken.data;
    return accessToken;
  }
}
