import 'package:flutter/material.dart';

import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.title,
    required this.width,
    required this.value,
    this.detail,
    required this.icon,
  });

  final double width;
  final String title;
  final String value;
  final String? detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(icon, color: colorScheme.primary, size: 16),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(title, style: theme.textTheme.titleMedium),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(value, style: theme.textTheme.headlineMedium),
              if (detail != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(detail!, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
