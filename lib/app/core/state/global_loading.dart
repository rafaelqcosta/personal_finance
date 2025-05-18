// global_loading_store.dart
import 'package:flutter/material.dart';

class GlobalLoadingStore {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  ValueNotifier<bool> get isLoading => _isLoading;

  void show() => _isLoading.value = true;
  void hide() => _isLoading.value = false;
}
