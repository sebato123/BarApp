// lib/core/app_prefs.dart
import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _hasBarKitKey = 'has_bar_kit';
  static const _difficultyFilterKey = 'difficulty_filter';

  // --- Kit de bartender ---
  static Future<bool> getHasBarKit() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_hasBarKitKey) ?? false;
  }

  static Future<void> setHasBarKit(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_hasBarKitKey, value);
  }

  // --- Filtro de dificultad ---
  // valores posibles: 'fácil', 'intermedio', 'difícil'
  static Future<String> getDifficultyFilter() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_difficultyFilterKey) ?? 'difícil'; // por defecto ve todo
  }

  static Future<void> setDifficultyFilter(String value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_difficultyFilterKey, value);
  }
}
