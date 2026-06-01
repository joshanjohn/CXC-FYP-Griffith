import 'package:flutter/material.dart';
import 'package:cxc/app/themes/app_colors.dart';
import 'package:cxc/features/auth/controllers/auth_controller.dart';
import 'package:cxc/shared/responsive/responsive_helper.dart';
import 'package:cxc/shared/widgets/adaptive_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController authController = AuthController();
  bool isSigningOut = false;
  bool isDeleting = false;

  Future<void> handleSignOut() async {
    setState(() => isSigningOut = true);

    try {
      await authController.logout();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => isSigningOut = false);
      }
    }
  }

  Future<void> handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete account?'),
          content: const Text(
            'This will permanently delete your account and personal information. '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete permanently'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => isDeleting = true);

    try {
      await authController.deleteCurrentUserAccount();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => isDeleting = false);
      }
    }
  }

  String displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Not provided';
    }
    return value;
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = authController.currentUser;
    final maxWidth = ResponsiveHelper.getMaxContentWidth(context);
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark
        ? AppColors.outlineDark
        : AppColors.outlineLight.withValues(alpha: 0.7);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final infoRows = <MapEntry<String, String>>[
      MapEntry('Email', displayValue(user.email)),
    ];

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: ResponsiveHelper.getResponsivePadding(context),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.onSurfaceLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'View the personal information currently stored for your account, then sign out or remove the account entirely.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppColors.onSurfaceLight.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.12,
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: AppColors.primary,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayValue(user.email),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.onSurfaceLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        ...infoRows.map(
                          (entry) => _InfoTile(
                            label: entry.key,
                            value: entry.value,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account actions',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : AppColors.onSurfaceLight,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Deleting your account will permanently delete your personal information from this app.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.7)
                                : AppColors.onSurfaceLight.withValues(
                                    alpha: 0.7,
                                  ),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: 220,
                              child: AdaptiveButton(
                                text: 'Sign Out',
                                icon: Icons.logout_rounded,
                                onPressed: handleSignOut,
                                isLoading: isSigningOut,
                                isPrimary: false,
                                width: double.infinity,
                              ),
                            ),
                            SizedBox(
                              width: 260,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: isDeleting
                                    ? null
                                    : handleDeleteAccount,
                                icon: isDeleting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Icon(Icons.delete_forever_rounded),
                                label: Text(
                                  isDeleting
                                      ? 'Deleting account...'
                                      : 'Delete Account',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : AppColors.onSurfaceLight.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.onSurfaceLight,
            ),
          ),
        ],
      ),
    );
  }
}
