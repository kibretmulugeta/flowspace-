import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/auth_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../settings_provider.dart';
import 'appearance_screen.dart';
import 'backup_sync_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final settingsState = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // ACCOUNT SECTION
          Text('ACCOUNT', style: AppTypography.labelSmall.copyWith(color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 8),
          _buildSettingsCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Display Name'),
                subtitle: Text(user?.displayName ?? AppStrings.defaultUser),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                subtitle: Text(user?.email ?? 'kibret@flowspace.app'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.priorityUrgent),
                title: const Text('Sign Out', style: TextStyle(color: AppColors.priorityUrgent)),
                onTap: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // APPEARANCE SECTION
          Text('APPEARANCE', style: AppTypography.labelSmall.copyWith(color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 8),
          _buildSettingsCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Theme & Accent Color'),
                subtitle: Text(
                  '${_themeLabel(settingsState.themeMode)} • ${_accentLabel(settingsState.accentColor)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AppearanceScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // PRODUCTIVITY SETTINGS
          Text('PRODUCTIVITY', style: AppTypography.labelSmall.copyWith(color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 8),
          _buildSettingsCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Start of the Week'),
                trailing: DropdownButton<int>(
                  value: settingsState.startOfWeekDay,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Monday')),
                    DropdownMenuItem(value: 7, child: Text('Sunday')),
                  ],
                  onChanged: (val) {
                    if (val != null) settingsNotifier.setStartOfWeek(val);
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.snooze_outlined),
                title: const Text('Default Snooze Time'),
                trailing: DropdownButton<int>(
                  value: settingsState.defaultSnoozeMinutes,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5 mins')),
                    DropdownMenuItem(value: 15, child: Text('15 mins')),
                    DropdownMenuItem(value: 30, child: Text('30 mins')),
                    DropdownMenuItem(value: 60, child: Text('1 hour')),
                  ],
                  onChanged: (val) {
                    if (val != null) settingsNotifier.setSnoozeMinutes(val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // NOTIFICATIONS & DATA
          Text('DATA & SYNC', style: AppTypography.labelSmall.copyWith(color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 8),
          _buildSettingsCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('Local Notifications'),
                subtitle: const Text('Sound alerts and scheduled task alarms'),
                value: settingsState.notificationsEnabled,
                onChanged: (val) => settingsNotifier.toggleNotifications(val),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined, color: AppColors.accentIndigo),
                title: const Text('Test Screen Alert Banner'),
                subtitle: const Text('Preview in-app heads-up notification card'),
                trailing: const Icon(Icons.play_arrow_rounded),
                onTap: () {
                  ref.read(notificationServiceProvider.notifier).triggerTestNotification(type: 'task');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.language, color: AppColors.accentCyan),
                title: const Text('Enable Browser Notifications'),
                subtitle: const Text('Allow Safari / Chrome to push desktop & mobile alerts'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final granted = await ref.read(notificationServiceProvider.notifier).requestBrowserPermission();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(granted
                            ? 'Browser notifications enabled!'
                            : 'Notification permission not granted in browser settings'),
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.storage, color: AppColors.accentEmerald),
                title: const Text('Database & Workspace Storage'),
                subtitle: const Text('Connected • Persistent Key-Value & Document Engine'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BackupSyncScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ABOUT SECTION
          Text('ABOUT', style: AppTypography.labelSmall.copyWith(color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 8),
          _buildSettingsCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                subtitle: const Text('${AppConstants.appName} v${AppConstants.appVersion} (Production Build)'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  String _accentLabel(Color color) {
    if (color.toARGB32() == AppColors.accentIndigo.toARGB32()) return 'Indigo';
    if (color.toARGB32() == AppColors.accentEmerald.toARGB32()) return 'Emerald';
    if (color.toARGB32() == AppColors.accentViolet.toARGB32()) return 'Violet';
    if (color.toARGB32() == AppColors.accentRose.toARGB32()) return 'Rose';
    if (color.toARGB32() == AppColors.accentAmber.toARGB32()) return 'Amber';
    if (color.toARGB32() == AppColors.accentCyan.toARGB32()) return 'Cyan';
    return 'Custom';
  }
}
