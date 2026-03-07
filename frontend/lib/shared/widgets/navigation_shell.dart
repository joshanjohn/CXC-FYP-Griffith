import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../shared/responsive/responsive_helper.dart';
import '../../features/prediction/pages/workspace_page.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      body: Column(
        children: [
          if (!isMobile) _buildDesktopHeader(context, theme),
          const Expanded(child: WorkspacePage()),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'CHEST X-RAY ML',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
