import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) => ThemeModeController(),
);

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.system) {
    _restore();
  }

  static const _storage = FlutterSecureStorage();
  static const _key = 'jce.appearance';
  Future<void> _pendingWrite = Future.value();
  bool _chosen = false;

  Future<void> _restore() async {
    try {
      final saved = await _storage.read(key: _key);
      if (mounted && !_chosen && (saved == 'light' || saved == 'dark')) {
        state = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
      }
    } on Exception {
      // Use system appearance when device storage is unavailable.
    }
  }

  void select(ThemeMode mode) {
    _chosen = true;
    state = mode;
    _pendingWrite = _pendingWrite.then((_) async {
      try {
        await _storage.write(key: _key, value: mode.name);
      } on Exception {
        // Keep the selected appearance for this session.
      }
    });
  }
}
