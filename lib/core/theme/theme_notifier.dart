import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String _boxName = 'settings';
const String _themeKey = 'isDarkMode';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  try {
    final box = Hive.box<dynamic>(_boxName);
    return ThemeModeNotifier(box);
  } on Exception {
    return ThemeModeNotifier(null);
  }
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Box<dynamic>? _box;

  ThemeModeNotifier(this._box) : super(_getInitialThemeMode(_box));

  void toggle() {
    if (_box == null) {
      state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      return;
    }

    final isDark = state == ThemeMode.dark;
    try {
      _box.put(_themeKey, !isDark);
    } on Exception {
      // Handle Hive write error silently
    }
    state = isDark ? ThemeMode.light : ThemeMode.dark;
  }

  static ThemeMode _getInitialThemeMode(Box<dynamic>? box) {
    if (box == null) return ThemeMode.light;
    try {
      final value = box.get(_themeKey);
      if (value == null) return ThemeMode.light;
      final isDark = value as bool;
      return isDark ? ThemeMode.dark : ThemeMode.light;
    } on Exception {
      return ThemeMode.light;
    }
  }
}
