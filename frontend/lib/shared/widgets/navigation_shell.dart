import 'package:flutter/material.dart';
import 'package:frontend/app/themes/app_colors.dart';
import 'package:frontend/shared/responsive/responsive_helper.dart';
import 'package:frontend/features/prediction/view/pages/dashboard_page.dart';

import 'package:frontend/app/routes.dart';

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
          const Expanded(child: DashboardPage()),
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
                'CXC (Chest X-ray Classifier)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 48),
              _buildNavButton(
                context,
                label: 'Dashboard',
                isActive: true,
                onTap: () {},
              ),
              const SizedBox(width: 24),
              _buildNavButton(
                context,
                label: 'Batch Classification',
                isActive: false,
                onTap: () => Navigator.pushNamed(context, AppRoutes.batch),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required String label,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.primary : null,
          ),
        ),
      ),
    );
  }
}
