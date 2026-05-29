import 'package:flutter/material.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../shared/responsive/responsive_helper.dart';
import '../../../../shared/widgets/adaptive_button.dart';
import '../widgets/auth_text_field.dart';
import 'signup_page.dart';
import '../../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoggingIn = false;
  final authController = AuthController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => isLoggingIn = true);

    try {
      await authController.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (mounted) {
        setState(() => isLoggingIn = false);
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoggingIn = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: ResponsiveHelper.getResponsivePadding(context),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                children: [
                  // app icon / logo
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 1),
                    ),
                    child: const Icon(
                      Icons.health_and_safety_rounded,
                      size: 44,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'CXC (Chest X-ray Classifier)',
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
                      color: isDark ? Colors.white : AppColors.onSurfaceLight,
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

                  // email & password fields
                  AuthTextField(
                    controller: emailController,
                    label: 'EMAIL ADDRESS',
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 24),
                  AuthTextField(
                    controller: passwordController,
                    label: 'PASSWORD',
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),
                  const SizedBox(height: 24),

                  // login button
                  AdaptiveButton(
                    text: 'Enter Workspace',
                    onPressed: handleLogin,
                    isLoading: isLoggingIn,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 24),

                  // link to signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
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
                          'Create Account',
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
    );
  }
}
