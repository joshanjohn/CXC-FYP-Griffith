import 'package:flutter/material.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/responsive/responsive_helper.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent, // Shell handles background
      body: SingleChildScrollView(
        padding: ResponsiveHelper.getResponsivePadding(context),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // User Header
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(
                  AppConstants.radiusExtraLarge,
                ),
                border: Border.all(
                  color: AppColors.primary.withValues(
                    alpha: isDark ? 0.2 : 0.15,
                  ),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: isDark ? 0.05 : 0.08,
                    ),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: AppColors.primaryGradient,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'JJ',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Joshan John',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chief Medical Analyst',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : AppColors.onSurfaceLight.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStat(context, 'Analyses', '124'),
                      _buildDivider(isDark),
                      _buildStat(context, 'Accuracy', '98%'),
                      _buildDivider(isDark),
                      _buildStat(context, 'Reports', '42'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings Section
            _buildSection(context, 'Account Settings', isDark, [
              _buildListTile(
                context,
                'Personal Information',
                Icons.person_outline_rounded,
              ),
              _buildListTile(
                context,
                'Privacy & Security',
                Icons.lock_outline_rounded,
              ),
              _buildListTile(
                context,
                'Notifications',
                Icons.notifications_none_rounded,
              ),
            ]),
            const SizedBox(height: 24),

            _buildSection(context, 'Diagnostic History', isDark, [
              _buildListTile(
                context,
                'Patient Archive',
                Icons.folder_open_rounded,
              ),
              _buildListTile(
                context,
                'ML Model Performance',
                Icons.analytics_outlined,
              ),
            ]),
            const SizedBox(height: 48),

            // Logout Button
            TextButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: Text(
                'Log Out',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 30,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : AppColors.onSurfaceLight.withValues(alpha: 0.15),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    bool isDark,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: isDark
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                  : AppColors.onSurfaceLight.withValues(alpha: 0.5),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.cardDark.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.12),
              width: 1,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
      onTap: () {},
    );
  }
}
