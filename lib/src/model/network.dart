class Network {
  final String _key;
  final int chainId;

  const Network._(this._key, this.chainId);

  static const mainNet = Network._("mainnet", 1);
  static const testNet = Network._("testnet", 2);
  static const devNet = Network._("devnet", 3);
  static const local = Network._("local", 4);
  static const custom = Network._("custom", 5);

  static List<Network> options = [mainNet, testNet, devNet, local, custom];

  static Network? parseKey(String key) {
    final query = options.where((e) => e._key == key);
    if (query.isEmpty) {
      return null;
    }
    return query.first;
  }

  static Network? parseChainId(int chainId) {
    final query = options.where((e) => e.chainId == chainId);
    if (query.isEmpty) {
      return null;
    }
    return query.first;
  }

  @override
  String toString() {
    return _key;
  }
}
