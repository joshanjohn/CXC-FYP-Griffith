import 'package:flutter/material.dart';
import 'package:frontend/features/docs/view/pages/model_info_detail_page.dart';
import 'package:frontend/features/prediction/view/pages/image_preview_page.dart';
import 'package:frontend/features/prediction/view/pages/permission_error_page.dart';
import 'package:frontend/features/auth/view/pages/login_page.dart';
import 'package:frontend/features/auth/view/pages/signup_page.dart';
import 'package:frontend/shared/widgets/navigation_shell.dart';

import 'package:frontend/shared/widgets/auth_wrapper.dart';

class AppRoutes {
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

  static Map<String, WidgetBuilder> get routes => {
    shell: (context) => const AuthWrapper(),
    login: (context) => const LoginPage(),
    signup: (context) => const SignupPage(),
    workspace: (context) => const MainShell(initialIndex: 0),
    batch: (context) => const MainShell(initialIndex: 2),
    docs: (context) => const MainShell(initialIndex: 3),
    profile: (context) => const MainShell(initialIndex: 4),
    error: (context) =>
        const PermissionErrorPage(permissionName: '', description: ''),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == preview) {
      final source = settings.arguments;
      return MaterialPageRoute(
        builder: (context) => ImagePreviewPage(imageSource: source),
      );
    }
    if (settings.name != null && settings.name!.startsWith('$docsModelBase/')) {
      final modelName = settings.name!.substring('$docsModelBase/'.length);
      return MaterialPageRoute(
        builder: (context) => ModelInfoDetailPage(modelName: modelName),
      );
    }
    return null;
  }
}
