enum EphemeralSignatureVariant {
  ed25519._(0);

  const EphemeralSignatureVariant._(int value) : _underline = value;

  final int _underline;

  int get value => _underline;
}

enum EphemeralPublicKeyVariant {
  ed25519._(0);

  const EphemeralPublicKeyVariant._(int value) : _underline = value;

  final int _underline;

  int get value => _underline;
}
