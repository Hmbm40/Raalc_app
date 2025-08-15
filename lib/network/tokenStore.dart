import 'package:hooks_riverpod/hooks_riverpod.dart';

class TokenPair {
  final String accessToken;
  final String? refreshToken;
  const TokenPair(this.accessToken, [this.refreshToken]);
}

class InMemoryTokenStore extends StateNotifier<TokenPair?> {
  InMemoryTokenStore() : super(null);
  void save(TokenPair? pair) => state = pair;
}

final tokenStoreProvider = StateNotifierProvider<InMemoryTokenStore, TokenPair?>((_) => InMemoryTokenStore());
