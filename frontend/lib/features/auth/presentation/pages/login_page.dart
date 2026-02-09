import 'package:flutter/material.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../shared/responsive/responsive_helper.dart';
import '../../../../shared/widgets/adaptive_button.dart';
import '../widgets/auth_text_field.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() => _isLoggingIn = true);
    // Simulate login
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoggingIn = false);
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background Gradient
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

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: ResponsiveHelper.getResponsivePadding(context),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    children: [
                      // Logo / Icon with Pulse Glow
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.health_and_safety_rounded,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'CHEST X-RAY ML',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome Back',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          color: isDark
                              ? Colors.white
                              : AppColors.onSurfaceLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to your diagnostic station',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : AppColors.onSurfaceLight.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Form Fields
                      AuthTextField(
                        controller: _emailController,
                        label: 'IDENTIFICATION',
                        hint: 'name@hospital.com',
                        icon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      AuthTextField(
                        controller: _passwordController,
                        label: 'SECURITY KEY',
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                      ),
                      const SizedBox(height: 12),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Recover Access',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Login Button
                      AdaptiveButton(
                        text: 'Enter Workspace',
                        onPressed: _handleLogin,
                        isLoading: _isLoggingIn,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 24),

                      // Signup Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "New to the network?",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Request Access',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
