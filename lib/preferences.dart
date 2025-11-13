// lib/preferences.dart
import 'package:flutter/foundation.dart';          // <- para debugPrint
import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _keyHasBarKit = 'has_bar_kit';
  static const _keyDifficultyFilter = 'difficulty_filter';
  static const _keyTrainingMode = 'training_mode_enabled';
  static const _keyGlassGuide = 'glass_guide_enabled';

  // ---------- Kit de bar ----------
  static Future<bool> getHasBarKit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyHasBarKit) ?? false;
    } catch (e) {
      debugPrint('Error SharedPreferences getHasBarKit: $e');
      return false;
    }
  }

  static Future<void> setHasBarKit(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasBarKit, value);
    } catch (e) {
      debugPrint('Error SharedPreferences setHasBarKit: $e');
    }
  }

  // ---------- Dificultad ----------
  // valores esperados: 'fácil', 'intermedio', 'difícil'
  static Future<String> getDifficultyFilter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyDifficultyFilter) ?? 'difícil';
    } catch (e) {
      debugPrint('Error SharedPreferences getDifficultyFilter: $e');
      return 'difícil';
    }
  }

  static Future<void> setDifficultyFilter(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyDifficultyFilter, value);
    } catch (e) {
      debugPrint('Error SharedPreferences setDifficultyFilter: $e');
    }
  }

  // ---------- Training Mode ----------
  static Future<bool> getTrainingModeEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyTrainingMode) ?? false;
    } catch (e) {
      debugPrint('Error SharedPreferences getTrainingModeEnabled: $e');
      return false;
    }
  }

  static Future<void> setTrainingModeEnabled(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyTrainingMode, value);
    } catch (e) {
      debugPrint('Error SharedPreferences setTrainingModeEnabled: $e');
    }
  }

  // ---------- Guía de vasos ----------
  static Future<bool> getGlassGuideEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyGlassGuide) ?? true; // por defecto activado
    } catch (e) {
      debugPrint('Error SharedPreferences getGlassGuideEnabled: $e');
      return true;
    }
  }

  static Future<void> setGlassGuideEnabled(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyGlassGuide, value);
    } catch (e) {
      debugPrint('Error SharedPreferences setGlassGuideEnabled: $e');
    }
  }
}