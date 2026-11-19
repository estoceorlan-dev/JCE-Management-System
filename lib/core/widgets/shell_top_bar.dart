import 'package:flutter/material.dart';

import '../../features/auth/domain/entities/auth_session.dart';
import '../../shared/models/sync_state.dart';
import 'theme_mode_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'branch_selector.dart';

class ShellTopBar extends StatelessWidget {
  const ShellTopBar({
    super.key,
    required this.title,
    required this.session,
    required this.sidebarToggle,
    required this.isDesktop,
    required this.onBranchSelected,
    required this.onRefreshAccess,
    required this.syncState,
    required this.onSync,
    this.onOfflinePin,
    this.onSwitchCashier,
  });

  final String title;
  final AuthSession session;
  final Widget? sidebarToggle;
  final bool isDesktop;
  final BranchSelectionCallback onBranchSelected;
  final VoidCallback onRefreshAccess;
  final SyncState? syncState;
  final VoidCallback onSync;
  final VoidCallback? onOfflinePin;
  final VoidCallback? onSwitchCashier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final narrow = MediaQuery.sizeOf(context).width < 600;

    return Container(
      height: isDesktop ? 60 : 56,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppSpacing.xxl : AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.slate200,
          ),
        ),
      ),
      child: Row(
        children: [
          if (sidebarToggle != null) ...[
            sidebarToggle!,
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge,
            ),
          ),
          if (!narrow && onOfflinePin != null)
            IconButton(
              tooltip: 'Offline cashier PIN',
              onPressed: onOfflinePin,
              icon: const Icon(Icons.pin_outlined),
            ),
          if (!narrow && onSwitchCashier != null)
            IconButton(
              tooltip: 'Switch cashier',
              onPressed: onSwitchCashier,
              icon: const Icon(Icons.switch_account_outlined),
            ),
          const ThemeModeButton(),
          IconButton(
            tooltip: syncState?.message ?? 'Synchronize now',
            onPressed: syncState?.status == SyncStatus.syncing ? null : onSync,
            icon: syncState?.status == SyncStatus.syncing
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(switch (syncState?.status) {
                    SyncStatus.offline => Icons.cloud_off_outlined,
                    SyncStatus.failed => Icons.sync_problem_outlined,
                    _ =>
                      (syncState?.failedChanges ?? 0) > 0 ||
                              (syncState?.conflicts ?? 0) > 0
                          ? Icons.sync_problem_outlined
                          : Icons.cloud_sync_outlined,
                  }),
          ),
          if (isDesktop) const SizedBox(width: AppSpacing.sm),
          if (narrow)
            PopupMenuButton<VoidCallback>(
              tooltip: 'More actions',
              onSelected: (action) => action(),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: onRefreshAccess,
                  child: const Text('Refresh access'),
                ),
                if (onOfflinePin != null)
                  PopupMenuItem(
                    value: onOfflinePin,
                    child: const Text('Offline cashier PIN'),
                  ),
                if (onSwitchCashier != null)
                  PopupMenuItem(
                    value: onSwitchCashier,
                    child: const Text('Switch cashier'),
                  ),
              ],
            )
          else
            IconButton(
              tooltip: 'Refresh access',
              onPressed: onRefreshAccess,
              icon: const Icon(Icons.refresh),
            ),
          if (isDesktop) const SizedBox(width: AppSpacing.sm),
          BranchSelector(
            key: const ValueKey('app-bar-branch-selector'),
            session: session,
            compact: narrow,
            maxWidth: isDesktop ? 232 : 136,
            onSelected: onBranchSelected,
          ),
        ],
      ),
    );
  }
}
