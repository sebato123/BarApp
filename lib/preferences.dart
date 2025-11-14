import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _keyHasBarKit = 'has_bar_kit';
  static const _keyDifficultyFilter = 'difficulty_filter';
  static const _keyTrainingMode = 'training_mode_enabled';
  static const _keyGlassGuide = 'glass_guide_enabled';

  // NUEVO:
  static const _keyUseGridView = 'cocteles_grid_view';
  static const _keyShowInfoChips = 'show_info_chips';

  // ---------- Kit de bar ----------
  static Future<bool> getHasBarKit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasBarKit) ?? false;
  }

  static Future<void> setHasBarKit(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasBarKit, value);
  }

  // ---------- Dificultad ----------
  static Future<String> getDifficultyFilter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDifficultyFilter) ?? 'difícil';
  }

  static Future<void> setDifficultyFilter(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDifficultyFilter, value);
  }

  // ---------- Training Mode ----------
  static Future<bool> getTrainingModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTrainingMode) ?? false;
  }

  static Future<void> setTrainingModeEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTrainingMode, value);
  }

  // ---------- Guía de vasos ----------
  static Future<bool> getGlassGuideEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyGlassGuide) ?? true;
  }

  static Future<void> setGlassGuideEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGlassGuide, value);
  }

  // ---------- NUEVO: Vista en grilla ----------
  static Future<bool> getUseGridView() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyUseGridView) ?? false; // por defecto lista
  }

  static Future<void> setUseGridView(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseGridView, value);
  }

  // ---------- NUEVO: Mostrar chips ----------
  static Future<bool> getShowInfoChips() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyShowInfoChips) ?? true; // por defecto visibles
  }

  static Future<void> setShowInfoChips(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowInfoChips, value);
  }
}