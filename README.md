Aptos Core package contains primitives and models for interacting with Aptos Blockchain.

It is partial port of aptos ts sdk.

Port focused on Keyless Accounts, rather than plain keypair generation. 

Library contains:

1. BCS serialization. It is basic serialization in aptos.
2. Crypto models. Implemented base ed25519 algorithm.
3. Base models like Account address, and Network.

Usage example:

```dart
import 'package:aptos_core/aptos_core.dart';

Future<void> main() async {
  final algorithm = Ed25519Algorithm();
  final privateKey = await algorithm.generatePrivateKey();
  final publicKey = await privateKey.getPublicKey();
}


```

All operations on crypto models like generatePrivateKey, signMessage, verifySignature are asynchronous for flexibility.


It is base for flutter_aptos_connect and flutter_aptos_keyless package.

Feel free to contribute to project.

