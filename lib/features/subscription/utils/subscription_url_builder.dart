import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

/// Builds a signed subscription URL using AES-256-CBC encryption.
///
/// Token is encrypted INSIDE [sig] â€” never exposed in plain text.
///
/// Query params:
///   - `ts`  â†’ Unix timestamp (seconds)
///   - `sig` â†’ AES-256-CBC encrypted "$token|$timestamp" (base64url, no padding)
///
/// Server decrypts [sig] using same [sharedSecret] + timestamp-derived IV
/// â†’ extracts token â†’ uses as Bearer for API calls.
String buildSubscriptionUrl({
  required String token,
  required String sharedSecret,
  required String baseUrl,
}) {
  final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final message = '$token|$timestamp';

  // 32-byte AES-256 key (pad/truncate sharedSecret)
  final rawKey = utf8.encode(sharedSecret);
  final keyBytes = Uint8List(32);
  for (var i = 0; i < rawKey.length && i < 32; i++) {
    keyBytes[i] = rawKey[i];
  }

  // Deterministic 16-byte IV from timestamp
  final tsStr = timestamp.toString().padLeft(16, '0');
  final ivBytes = Uint8List.fromList(
    utf8.encode(tsStr.substring(tsStr.length - 16)),
  );

  final encrypter = Encrypter(AES(Key(keyBytes), mode: AESMode.cbc));
  final encrypted = encrypter.encrypt(message, iv: IV(ivBytes));

  // base64url without padding
  final sig = base64Url.encode(encrypted.bytes).replaceAll('=', '');

  // token à¦†à¦° plain text à¦ à¦¨à¦¾à¦‡ â€” à¦¶à§à¦§à§ sig à¦à¦° à¦­à§‡à¦¤à¦°à§‡
  return '$baseUrl?ts=$timestamp&sig=$sig';
}

/// Decrypts a signed subscription URL's sig param back into
/// the original token, validating timestamp integrity and freshness.
///
/// Valid window: 30 minutes from generation.
///
/// NOTE: token à¦¨à¦¿à¦œà§‡à¦‡ '|' character à¦§à¦¾à¦°à¦£ à¦•à¦°à¦¤à§‡ à¦ªà¦¾à¦°à§‡ (à¦¯à§‡à¦®à¦¨ "50|IeUY2m...").
/// à¦¤à¦¾à¦‡ decrypted payload à¦•à§‡ à¦ªà§à¦°à¦¥à¦® '|' à¦¦à¦¿à¦¯à¦¼à§‡ split à¦¨à¦¾ à¦•à¦°à§‡, à¦¸à¦¬à¦¸à¦®à¦¯à¦¼
/// *à¦¶à§‡à¦·* '|' à¦•à§‡ delimiter à¦¹à¦¿à¦¸à§‡à¦¬à§‡ à¦§à¦°à¦¾ à¦¹à¦¯à¦¼à§‡à¦›à§‡ â€” à¦•à¦¾à¦°à¦£ timestamp à¦¸à¦¬à¦¸à¦®à¦¯à¦¼
/// à¦¶à§‡à¦·à§‡ à¦¥à¦¾à¦•à§‡ à¦à¦¬à¦‚ à¦¶à§à¦§à§ digit à¦¦à¦¿à¦¯à¦¼à§‡ à¦—à¦ à¦¿à¦¤à¥¤
// String decryptSubscriptionSig({
//   required String sig,
//   required int timestamp, // from the ts query param
//   required String sharedSecret,
// }) {
//   const maxAgeSeconds = 30 * 60; // 30 minutes
//
//   // Rebuild the same 32-byte AES-256 key
//   final rawKey = utf8.encode(sharedSecret);
//   final keyBytes = Uint8List(32);
//   for (var i = 0; i < rawKey.length && i < 32; i++) {
//     keyBytes[i] = rawKey[i];
//   }
//
//   // Rebuild the same deterministic IV from timestamp
//   final tsStr = timestamp.toString().padLeft(16, '0');
//   final ivBytes = Uint8List.fromList(
//     utf8.encode(tsStr.substring(tsStr.length - 16)),
//   );
//
//   // Restore base64url padding before decoding
//   var padded = sig.replaceAll('-', '+').replaceAll('_', '/');
//   while (padded.length % 4 != 0) {
//     padded += '=';
//   }
//   final encryptedBytes = base64.decode(padded);
//
//   final encrypter = Encrypter(AES(Key(keyBytes), mode: AESMode.cbc));
//   final decrypted = encrypter.decrypt(
//     Encrypted(encryptedBytes),
//     iv: IV(ivBytes),
//   );
//
//   // decrypted = "$token|$timestamp"  (token à¦¨à¦¿à¦œà§‡à¦“ '|' à¦°à¦¾à¦–à¦¤à§‡ à¦ªà¦¾à¦°à§‡)
//   // à¦¤à¦¾à¦‡ à¦¶à§‡à¦· '|' à¦–à§à¦à¦œà§‡ à¦¸à§‡à¦Ÿà¦¾à¦•à§‡ delimiter à¦§à¦°à¦¾ à¦¹à¦šà§à¦›à§‡à¥¤
//   final sepIndex = decrypted.lastIndexOf('|');
//   if (sepIndex == -1) {
//     throw const FormatException('Malformed decrypted payload');
//   }
//
//   final token = decrypted.substring(0, sepIndex);
//   final embeddedTsStr = decrypted.substring(sepIndex + 1);
//   final embeddedTs = int.tryParse(embeddedTsStr);
//
//   if (token.isEmpty || embeddedTs == null) {
//     throw const FormatException('Malformed decrypted payload');
//   }
//
//   // ts param à¦†à¦° decrypted payload à¦à¦° timestamp à¦®à¦¿à¦²à¦›à§‡ à¦•à¦¿à¦¨à¦¾ (tampering check)
//   if (embeddedTs != timestamp) {
//     throw Exception('Timestamp mismatch â€” possible tampering');
//   }
//
//   // 30 à¦®à¦¿à¦¨à¦¿à¦Ÿà§‡à¦° à¦¬à§‡à¦¶à¦¿ à¦ªà§à¦°à¦¨à§‹ à¦¹à¦²à§‡ reject (replay protection)
//   final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//   if (now - timestamp > maxAgeSeconds || now - timestamp < -60) {
//     // -60: à¦¸à¦¾à¦®à¦¾à¦¨à§à¦¯ clock skew tolerate à¦•à¦°à¦¾à¦° à¦œà¦¨à§à¦¯ (future timestamp)
//     throw Exception('Signature expired or invalid timestamp');
//   }
//
//   return token;
// }

