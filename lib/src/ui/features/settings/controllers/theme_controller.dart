import 'package:flutter/material.dart';
import 'package:controle_horas/src/data/services/settings_service.dart';
import 'package:controle_horas/src/core/utils/system_config.dart';

class ThemeController extends ChangeNotifier {
  final SettingsService _settingsService;

  ThemeController(this._settingsService);

  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> init() async {
    _themeMode = await _settingsService.loadThemeMode();
    updateSystemUI(_themeMode);
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    updateSystemUI(_themeMode);
    notifyListeners();
    await _settingsService.saveThemeMode(_themeMode);
  }
}
