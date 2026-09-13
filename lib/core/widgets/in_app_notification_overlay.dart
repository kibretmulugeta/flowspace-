import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class InAppNotificationOverlay extends ConsumerWidget {
  final Widget child;

  const InAppNotificationOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(notificationServiceProvider);
    final banner = notifState.activeBanner;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        child,
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
                    ref.read(notificationServiceProvider.notifier).dismissBanner();
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2330) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Type Badge Icon
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

                              // Text Content
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
                                        GestureDetector(
                                          onTap: () {
                                            ref.read(notificationServiceProvider.notifier).dismissBanner();
                                          },
                                          child: Icon(
                                            Icons.close,
                                            size: 18,
                                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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

                          // Quick Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Snooze Button
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.snooze, size: 14),
                                label: const Text('Snooze 5m', style: TextStyle(fontSize: 12)),
                                onPressed: () {
                                  ref.read(notificationServiceProvider.notifier).snoozeItem(banner);
                                },
                              ),
                              const SizedBox(width: 8),

                              // Complete / Done Button
                              if (banner.payloadType == 'reminder' || banner.payloadType == 'task')
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: _getTypeColor(banner.payloadType),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.check, size: 14, color: Colors.white),
                                  label: const Text('Done', style: TextStyle(fontSize: 12, color: Colors.white)),
                                  onPressed: () {
                                    ref.read(notificationServiceProvider.notifier).completeItem(banner);
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .slideY(
                    begin: -1.2,
                    end: 0.0,
                    duration: 350.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 250.ms),
            ),
          ),
      ],
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
