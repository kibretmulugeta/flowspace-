import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// State representation for user settings
class SettingsState {
  final ThemeMode themeMode;
  final Color accentColor;
  final int defaultSnoozeMinutes;
  final int startOfWeekDay; // 1 = Monday, 7 = Sunday
  final bool notificationsEnabled;
  final bool offlineSyncEnabled;
  final bool isOnline;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.accentColor = AppColors.accentIndigo,
    this.defaultSnoozeMinutes = 15,
    this.startOfWeekDay = 1,
    this.notificationsEnabled = true,
    this.offlineSyncEnabled = true,
    this.isOnline = true,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
    int? defaultSnoozeMinutes,
    int? startOfWeekDay,
    bool? notificationsEnabled,
    bool? offlineSyncEnabled,
    bool? isOnline,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      defaultSnoozeMinutes: defaultSnoozeMinutes ?? this.defaultSnoozeMinutes,
      startOfWeekDay: startOfWeekDay ?? this.startOfWeekDay,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      offlineSyncEnabled: offlineSyncEnabled ?? this.offlineSyncEnabled,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
