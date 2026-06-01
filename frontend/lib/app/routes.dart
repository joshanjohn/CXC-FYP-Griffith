import 'package:flutter/material.dart';
import 'package:cxc/features/docs/models/model_info.dart';
import 'package:cxc/features/docs/view/pages/model_info_detail_page.dart';
import 'package:cxc/features/prediction/view/pages/image_preview_page.dart';
import 'package:cxc/features/prediction/view/pages/permission_error_page.dart';
import 'package:cxc/features/auth/view/pages/login_page.dart';
import 'package:cxc/features/auth/view/pages/signup_page.dart';
import 'package:cxc/shared/widgets/navigation_shell.dart';
import 'package:cxc/shared/widgets/auth_wrapper.dart';

class AppRoutes {
  // Route names used throughout the application
  static const String initial = '/';
  static const String shell = '/';
  static const String workspace = '/workspace';
  static const String preview = '/preview';
  static const String error = '/error';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String batch = '/batch';
  static const String docs = '/docs';
  static const String docsModelBase = '/docs/model';
  static const String profile = '/profile';

  // Application route configuration
  static Map<String, WidgetBuilder> get routes => {
    // Entry point with authentication check
    shell: (context) => const AuthWrapper(),

    // Authentication pages
    login: (context) => const LoginPage(),
    signup: (context) => const SignupPage(),

    // Main workspace screen
    workspace: (context) =>
        const AuthWrapper(authenticatedChild: MainShell(initialIndex: 0)),

    // Batch prediction screen
    batch: (context) =>
        const AuthWrapper(authenticatedChild: MainShell(initialIndex: 2)),

    // Documentation screen
    docs: (context) =>
        const AuthWrapper(authenticatedChild: MainShell(initialIndex: 3)),

    // User profile screen
    profile: (context) =>
        const AuthWrapper(authenticatedChild: MainShell(initialIndex: 4)),

    // Permission error screen
    error: (context) =>
        const PermissionErrorPage(permissionName: '', description: ''),
  };

  // Handle routes that require dynamic parameters
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {

    // Open image preview page with selected image source
    if (settings.name == preview) {
      final source = settings.arguments;

      return MaterialPageRoute(
        builder: (context) => AuthWrapper(
          authenticatedChild: ImagePreviewPage(imageSource: source),
        ),
      );
    }

    // Open model documentation detail page
    if (settings.name != null &&
        settings.name!.startsWith('$docsModelBase/')) {

      // Extract model name from route URL
      final modelName = settings.name!.substring(
        '$docsModelBase/'.length,
      );

      // Use preloaded model info if available
      final initialModelInfo = settings.arguments is ModelInfo
          ? settings.arguments as ModelInfo
          : null;

      return MaterialPageRoute(
        builder: (context) => AuthWrapper(
          authenticatedChild: ModelInfoDetailPage(
            modelName: modelName,
            initialModelInfo: initialModelInfo,
          ),
        ),
      );
    }

    // Return null for unknown routes
    return null;
  }
}