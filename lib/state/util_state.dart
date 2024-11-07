import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false);

  void on() {
    state = true;
  }

  void off() {
    state = false;
  }
}

final loadingProvider = StateNotifierProvider<LoadingNotifier, bool>((ref) => LoadingNotifier());

final indexProvider = StateProvider<int>((ref) => 0);
