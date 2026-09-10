import 'package:flutter/material.dart';
import '../theme/app_typography.dart';

/// Styled badge chip for priority, status, category, or tag display
class CustomBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool isFilled;
  final VoidCallback? onTap;

  const CustomBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.isFilled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: isFilled ? Colors.white : color),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isFilled ? Colors.white : color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final container = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isFilled ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: isFilled ? null : Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: effectiveContent,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: container,
      );
    }
    return container;
  }
}
