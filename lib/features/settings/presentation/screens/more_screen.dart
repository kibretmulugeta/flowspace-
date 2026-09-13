import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/auth_provider.dart';
import 'analytics_screen.dart';
import 'appearance_screen.dart';
import 'backup_sync_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navMore),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Account Profile Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    user != null && user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : 'K',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? AppStrings.defaultUser,
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'kibret@flowspace.app',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Core Features Section
          Text('Workspace', style: AppTypography.labelLarge),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            icon: Icons.rocket_launch_outlined,
            title: 'Projects',
            subtitle: 'Manage initiatives, milestones, and progress',
            color: AppColors.accentIndigo,
            onTap: () => Navigator.of(context).pushNamed('/projects'),
            isDark: isDark,
          ),
          _buildMenuItem(
            context,
            icon: Icons.category_outlined,
            title: 'Categories',
            subtitle: 'Organize tasks, notes, and events with custom colors',
            color: AppColors.accentTeal,
            onTap: () => Navigator.of(context).pushNamed('/categories'),
            isDark: isDark,
          ),
          _buildMenuItem(
            context,
            icon: Icons.bar_chart_rounded,
            title: 'Analytics & Focus Stats',
            subtitle: 'Productivity trends, velocity, and completion rates',
            color: AppColors.accentIndigo,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              );
            },
            isDark: isDark,
          ),
          _buildMenuItem(
            context,
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Themes, dark mode, and accent colors',
            color: AppColors.accentViolet,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AppearanceScreen()),
              );
            },
            isDark: isDark,
          ),
          _buildMenuItem(
            context,
            icon: Icons.sync,
            title: 'Backup & Sync',
            subtitle: 'Offline storage status, JSON import & export',
            color: AppColors.accentEmerald,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BackupSyncScreen()),
              );
            },
            isDark: isDark,
          ),
          _buildMenuItem(
            context,
            icon: Icons.alarm,
            title: 'Reminders & Notifications',
            subtitle: 'Manage upcoming alerts and alarms',
            color: AppColors.accentAmber,
            onTap: () => Navigator.of(context).pushNamed('/reminders'),
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          // App Information Section
          Text('System', style: AppTypography.labelLarge),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            icon: Icons.tune,
            title: 'Preferences',
            subtitle: 'Week start, calendar defaults, snooze intervals',
            color: AppColors.accentCyan,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            isDark: isDark,
          ),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: 'About FlowSpace',
            subtitle: 'Version ${AppConstants.appVersion} • Cross-platform Flutter',
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            onTap: () => _showAboutDialog(context),
            isDark: isDark,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.space_dashboard_rounded, color: Colors.white, size: 24),
      ),
      children: const [
        Text(
          'FlowSpace is a unified cross-platform productivity and scheduling workspace combining Notion, Google Calendar, and Todoist into an offline-first architecture.',
        ),
      ],
    );
  }
}
