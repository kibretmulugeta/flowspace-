import 'package:flutter/material.dart';
import '../theme/app_typography.dart';

/// Reusable subtle loading indicator view
class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: AppTypography.bodySmall),
          ],
        ],
      ),
    );
  }
}
