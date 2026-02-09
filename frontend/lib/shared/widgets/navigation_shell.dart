import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../shared/responsive/responsive_helper.dart';
import '../../features/analysis/presentation/pages/workspace_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [const WorkspacePage(), const ProfilePage()];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [AppColors.backgroundDark, AppColors.surfaceDark]
                      : AppColors.backgroundGradient,
                ),
              ),
            ),
          ),

          Column(
            children: [
              // Custom Header for Desktop/Tablet
              if (!isMobile) _buildDesktopHeader(context),

              Expanded(
                child: IndexedStack(index: _currentIndex, children: _pages),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildBottomNav(context) : null,
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo/Brand
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
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

          // Desktop Nav + Profile Avatar
          Row(
            children: [
              _buildNavButton(
                0,
                'Workspace',
                Icons.dashboard_customize_outlined,
              ),
              const SizedBox(width: 8),
              _buildNavButton(1, 'Research', Icons.menu_book_rounded),
              const SizedBox(width: 24),

              // Profile Avatar Trigger
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 1),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _currentIndex == 1
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Text(
                      'JJ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(int index, String label, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = _currentIndex == index;

    return TextButton.icon(
      onPressed: () => setState(() => _currentIndex = index),
      icon: Icon(
        icon,
        size: 20,
        color: isSelected
            ? AppColors.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isSelected
              ? AppColors.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: isSelected
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.cardDark.withValues(alpha: 0.95),
                  AppColors.surfaceDark.withValues(alpha: 0.95),
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.9),
                ],
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 25,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          if (isDark)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 40,
              offset: const Offset(0, 0),
            ),
        ],
        border: Border.all(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.primary.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home_rounded, 'Home', isDark),
            _buildNavItem(1, Icons.person_rounded, 'Profile', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.grey.withValues(alpha: 0.6),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.grey.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
