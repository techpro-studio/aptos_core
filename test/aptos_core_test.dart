import 'package:aptos_core/aptos_core.dart';

void main() async {
  final account = SingleKeyAccount.fromDerivationPath(
    "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
  );
  final key = account.privateKey.toUint8List().toHex();
  print("Key $key");
}
