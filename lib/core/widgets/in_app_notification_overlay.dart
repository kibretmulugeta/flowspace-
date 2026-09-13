import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/reminders/domain/notification_model.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class InAppNotificationOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const InAppNotificationOverlay({super.key, required this.child});

  @override
  ConsumerState<InAppNotificationOverlay> createState() => _InAppNotificationOverlayState();
}

class _InAppNotificationOverlayState extends ConsumerState<InAppNotificationOverlay> {
  bool _showSnoozeOptions = false;

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationServiceProvider);
    final banner = notifState.activeBanner;
    final totalCount = notifState.bannerCount;
    final feedback = notifState.feedbackToast;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base application
        widget.child,

        // Feedback Toast (e.g., "⏰ Snoozed for 10 min (Will alert at 18:05)")
        if (feedback != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(feedback),
                    tween: Tween<double>(begin: -0.5, end: 0.0),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    builder: (context, val, animChild) {
                      return Transform.translate(
                        offset: Offset(0, val * 30),
                        child: Opacity(
                          opacity: (1.0 + val * 2).clamp(0.0, 1.0),
                          child: animChild,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.accentIndigo.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              feedback,
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              ref.read(notificationServiceProvider.notifier).clearFeedbackToast();
                            },
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Persistent Alert Banner (Stays until removed)
        if (banner != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Dismissible(
                  key: ValueKey(banner.id),
                  direction: DismissDirection.up,
                  onDismissed: (_) {
                    setState(() => _showSnoozeOptions = false);
                    ref.read(notificationServiceProvider.notifier).dismissBanner(banner.id);
                  },
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(banner.id),
                    tween: Tween<double>(begin: -1.0, end: 0.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, animChild) {
                      return Transform.translate(
                        offset: Offset(0, value * 50),
                        child: Opacity(
                          opacity: (1.0 + value).clamp(0.0, 1.0),
                          child: animChild,
                        ),
                      );
                    },
                    child: Material(
                      elevation: 8,
                      shadowColor: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
                      borderRadius: BorderRadius.circular(16),
                      color: isDark ? const Color(0xFF1E2330) : Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getTypeColor(banner.payloadType).withValues(alpha: 0.45),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header Row: Type Icon + Title + Multi-alert count + Close
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Type Icon Badge
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(banner.payloadType).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _getTypeIcon(banner.payloadType),
                                    color: _getTypeColor(banner.payloadType),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Text details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              banner.title,
                                              style: AppTypography.titleMedium.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),

                                          // Multi-alert indicator pill (if > 1)
                                          if (totalCount > 1) ...[
                                            Container(
                                              margin: const EdgeInsets.only(right: 8),
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _getTypeColor(banner.payloadType).withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                '1 of $totalCount',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: _getTypeColor(banner.payloadType),
                                                ),
                                              ),
                                            ),
                                          ],

                                          // Explicit Close / Remove Button
                                          InkWell(
                                            borderRadius: BorderRadius.circular(12),
                                            onTap: () {
                                              setState(() => _showSnoozeOptions = false);
                                              ref.read(notificationServiceProvider.notifier).dismissBanner(banner.id);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Icon(
                                                Icons.close,
                                                size: 20,
                                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        banner.body,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Action Buttons (Responsive Wrap)
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runSpacing: 6,
                              spacing: 8,
                              children: [
                                // Multi-alert Navigation buttons
                                if (totalCount > 1)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton.icon(
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        icon: const Icon(Icons.navigate_next, size: 16),
                                        label: const Text('Next', style: TextStyle(fontSize: 12)),
                                        onPressed: () {
                                          setState(() => _showSnoozeOptions = false);
                                          ref.read(notificationServiceProvider.notifier).nextBanner();
                                        },
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        onPressed: () {
                                          setState(() => _showSnoozeOptions = false);
                                          ref.read(notificationServiceProvider.notifier).dismissAll();
                                        },
                                        child: const Text('Clear All', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      ),
                                    ],
                                  ),

                                // Snooze + Done Buttons
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        visualDensity: VisualDensity.compact,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      icon: const Icon(Icons.snooze, size: 14),
                                      label: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('Snooze 10m', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                          const SizedBox(width: 4),
                                          Icon(
                                            _showSnoozeOptions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                            size: 14,
                                          ),
                                        ],
                                      ),
                                      onPressed: () {
                                        setState(() => _showSnoozeOptions = !_showSnoozeOptions);
                                      },
                                    ),
                                    if (banner.payloadType == 'reminder' || banner.payloadType == 'task') ...[
                                      const SizedBox(width: 8),
                                      FilledButton.icon(
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          visualDensity: VisualDensity.compact,
                                          backgroundColor: _getTypeColor(banner.payloadType),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.check, size: 14, color: Colors.white),
                                        label: const Text('Done', style: TextStyle(fontSize: 12, color: Colors.white)),
                                        onPressed: () {
                                          setState(() => _showSnoozeOptions = false);
                                          ref.read(notificationServiceProvider.notifier).completeItem(banner);
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),

                            // Noticeable Snooze Options Chips (Inline drawer)
                            if (_showSnoozeOptions) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF141822) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Select Snooze Duration:',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        _buildSnoozeChip(banner, 5, '5 min'),
                                        _buildSnoozeChip(banner, 10, '10 min (Default)', isDefault: true),
                                        _buildSnoozeChip(banner, 15, '15 min'),
                                        _buildSnoozeChip(banner, 30, '30 min'),
                                        _buildSnoozeChip(banner, 60, '1 hour'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSnoozeChip(AppNotification banner, int minutes, String label, {bool isDefault = false}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() => _showSnoozeOptions = false);
        ref.read(notificationServiceProvider.notifier).snoozeItem(
              banner,
              duration: Duration(minutes: minutes),
            );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDefault ? AppColors.accentAmber.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDefault ? AppColors.accentAmber : Colors.grey.withValues(alpha: 0.5),
            width: isDefault ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 13,
              color: isDefault ? AppColors.accentAmber : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isDefault ? FontWeight.bold : FontWeight.normal,
                color: isDefault ? AppColors.accentAmber : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'task':
        return AppColors.accentEmerald;
      case 'event':
        return AppColors.accentIndigo;
      case 'reminder':
      default:
        return AppColors.accentAmber;
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'task':
        return Icons.check_circle_outline;
      case 'event':
        return Icons.calendar_month_outlined;
      case 'reminder':
      default:
        return Icons.alarm;
    }
  }
}
