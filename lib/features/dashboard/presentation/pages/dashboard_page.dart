import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_breakpoints.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/metric_tile.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/utils/formatters.dart';
import '../providers/dashboard_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sync = ref.watch(syncStateProvider);
    final syncState = sync.asData?.value;
    final metrics = ref.watch(dashboardSummaryProvider);
    final summary = metrics.asData?.value;
    final missingMetric = metrics.hasError ? 'Unavailable' : '…';
    final syncMessage = sync.hasError
        ? 'Sync status unavailable'
        : 'Loading sync status…';
    final pending = syncState == null
        ? (sync.hasError ? 'Unavailable' : '…')
        : (syncState.pendingChanges +
                  syncState.retryingChanges +
                  syncState.failedChanges +
                  syncState.conflicts)
              .toString();

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < AppBreakpoints.compact
            ? AppSpacing.lg
            : AppSpacing.xxl;
        final availableWidth = math.min(
          AppSpacing.contentMaxWidth,
          constraints.maxWidth - horizontalPadding * 2,
        );
        final columns =
            ((availableWidth + AppSpacing.md) / (224 + AppSpacing.md))
                .floor()
                .clamp(1, 5);
        final tileWidth =
            (availableWidth - (columns - 1) * AppSpacing.md) / columns;
        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: AppSpacing.lg,
          ),
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.contentMaxWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: [
                        MetricTile(
                          width: tileWidth,
                          title: 'Sales today',
                          value: summary == null
                              ? missingMetric
                              : Formatters.currencyMinor(summary.netSalesMinor),
                          detail: summary == null
                              ? 'Completed transactions'
                              : '${summary.completedSales} completed transactions',
                          icon: Icons.payments_outlined,
                        ),
                        MetricTile(
                          width: tileWidth,
                          title: 'Open carts',
                          value: summary?.openCarts.toString() ?? missingMetric,
                          icon: Icons.shopping_bag_outlined,
                        ),
                        MetricTile(
                          width: tileWidth,
                          title: 'Low stock',
                          value:
                              summary?.lowStockItems.toString() ??
                              missingMetric,
                          icon: Icons.warning_amber_outlined,
                        ),
                        MetricTile(
                          width: tileWidth,
                          title: 'Estimated gross profit',
                          value: summary == null
                              ? missingMetric
                              : Formatters.currencyMinor(
                                  summary.grossProfitMinor,
                                ),
                          detail: 'Based on snapshotted item cost',
                          icon: Icons.trending_up_outlined,
                        ),
                        MetricTile(
                          width: tileWidth,
                          title: 'Pending sync',
                          value: pending,
                          detail: syncState == null
                              ? syncMessage
                              : syncState.message ??
                                    'Local changes waiting for the backend',
                          icon: Icons.cloud_sync_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sync diagnostics',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              syncState == null
                                  ? syncMessage
                                  : 'Pending ${syncState.pendingChanges}  •  '
                                        'Retrying ${syncState.retryingChanges}  •  '
                                        'Failed ${syncState.failedChanges}  •  '
                                        'Conflicts ${syncState.conflicts}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
