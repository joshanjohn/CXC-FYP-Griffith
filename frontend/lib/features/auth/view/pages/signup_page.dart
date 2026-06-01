import 'package:flutter/material.dart';
import '../../../../shared/responsive/responsive_helper.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../shared/widgets/adaptive_button.dart';
import '../widgets/auth_text_field.dart';
import '../../controllers/auth_controller.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isCreating = false;
  final authController = AuthController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleSignup() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => isCreating = true);

    try {
      await authController.signup(
        emailController.text.trim(),
        passwordController.text,
      );

      if (mounted) {
        setState(() => isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please sign in.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isCreating = false);
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
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : AppColors.onSurfaceLight,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: ResponsiveHelper.getResponsivePadding(context),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      children: [
                        Text(
                          'Establish Credentials',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            color: isDark
                                ? Colors.white
                                : AppColors.onSurfaceLight,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Register for the AI diagnostic network',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : AppColors.onSurfaceLight.withValues(
                                    alpha: 0.6,
                                  ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // form fields
                        AuthTextField(
                          controller: emailController,
                          label: 'EMAIL',
                          hint: 'name@gmail.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        AuthTextField(
                          controller: passwordController,
                          label: 'Password',
                          hint: 'Min. 8 characters',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                        ),
                        const SizedBox(height: 48),

                        // submit button
                        AdaptiveButton(
                          text: 'Request Credentials',
                          onPressed: handleSignup,
                          isLoading: isCreating,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 24),

                        // legal footer text
                        Text(
                          'By requesting access, you agree to our Protocol of Service and Data Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.3)
                                : AppColors.onSurfaceLight.withValues(
                                    alpha: 0.5,
                                  ),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
