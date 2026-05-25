import 'package:flutter/material.dart';
import 'package:cxc/app/themes/app_colors.dart';
import 'package:cxc/shared/responsive/responsive_helper.dart';

class PersistentTopNavItem {
  const PersistentTopNavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
}

class PersistentTopNav extends StatelessWidget {
  const PersistentTopNav({
    super.key,
    required this.items,
    this.title = 'CXC (Chest X-ray Classifier)',
  });

  final List<PersistentTopNavItem> items;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    return SafeArea(
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withValues(alpha: 0.97),
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.12),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 28,
            14,
            isMobile ? 16 : 28,
            14,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.health_and_safety_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Diagnostic Workspace',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      NavChip(item: items[i]),
                      if (i != items.length - 1) const SizedBox(width: 10),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavChip extends StatelessWidget {
  const NavChip({super.key, required this.item});

  final PersistentTopNavItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: item.isActive
              ? AppColors.primary.withValues(alpha: 0.12)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isActive
                ? AppColors.primary.withValues(alpha: 0.32)
                : theme.dividerColor.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 18,
              color: item.isActive ? AppColors.primary : null,
            ),
            const SizedBox(width: 8),
            Text(
              item.label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: item.isActive ? FontWeight.w800 : FontWeight.w600,
                color: item.isActive ? AppColors.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
