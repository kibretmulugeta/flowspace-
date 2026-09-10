import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/settings_state.dart';

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    Future.microtask(() => _loadFromPreferences());
    return const SettingsState();
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(AppConstants.keyThemeMode);
      final accentValue = prefs.getInt(AppConstants.keyAccentColor);

      ThemeMode mode = ThemeMode.system;
      if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
        mode = ThemeMode.values[themeIndex];
      }

      Color accent = AppColors.accentIndigo;
      if (accentValue != null) {
        accent = Color(accentValue);
      }

      state = state.copyWith(
        themeMode: mode,
        accentColor: accent,
      );
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.keyThemeMode, mode.index);
    } catch (_) {}
  }

  Future<void> setAccentColor(Color color) async {
    state = state.copyWith(accentColor: color);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.keyAccentColor, color.toARGB32());
    } catch (_) {}
  }

  void setSnoozeMinutes(int minutes) {
    state = state.copyWith(defaultSnoozeMinutes: minutes);
  }

  void setStartOfWeek(int day) {
    state = state.copyWith(startOfWeekDay: day);
  }

  void toggleNotifications(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
  }

  void toggleOfflineSync(bool enabled) {
    state = state.copyWith(offlineSyncEnabled: enabled);
  }

  void setOnlineStatus(bool isOnline) {
    state = state.copyWith(isOnline: isOnline);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
