import 'dart:convert';

class JWTBody {
  final String aud;
  final String iss;
  final String uidVal;

  JWTBody({required this.aud, required this.iss, required this.uidVal});
}

class JWTHeader {
  final String? typ;
  final String? alg;
  final String? kid;

  JWTHeader({this.typ, this.alg, this.kid});
}

final jsonBase64 = json.fuse(utf8.fuse(base64Url));

extension JWTStringExtension on String {
  JWTHeader getHeader() {
    final parts = split('.');

    dynamic header = jsonBase64.decode(base64Url.normalize(parts[0]));

    return JWTHeader(
      typ: header['typ'],
      alg: header['alg'],
      kid: header['kid'],
    );
  }

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
