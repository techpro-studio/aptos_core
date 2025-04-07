import 'dart:convert';

class JWTBody {
  final String aud;
  final String iss;
  final String uidVal;

  JWTBody({required this.aud, required this.iss, required this.uidVal});
}

final jsonBase64 = json.fuse(utf8.fuse(base64Url));

extension JWTStringExtension on String {
  JWTBody getJWTBody({String uidKey = 'sub'}) {
    final parts = split('.');

    dynamic payload;

    try {
      payload = jsonBase64.decode(base64Url.normalize(parts[1]));
    } catch (ex) {
      payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    }

    return JWTBody(
      aud: payload['aud'],
      iss: payload['iss'],
      uidVal: payload[uidKey],
    );
  }
}
