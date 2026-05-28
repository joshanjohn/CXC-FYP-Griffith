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
    workspace: (context) =>
        const AuthWrapper(authenticatedChild: MainShell(initialIndex: 0)),
    batch: (context) =>
        const AuthWrapper(authenticatedChild: MainShell(initialIndex: 2)),
    docs: (context) =>
        const AuthWrapper(authenticatedChild: MainShell(initialIndex: 3)),
    profile: (context) =>
        const AuthWrapper(authenticatedChild: MainShell(initialIndex: 4)),
    error: (context) =>
        const PermissionErrorPage(permissionName: '', description: ''),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == preview) {
      final source = settings.arguments;
      return MaterialPageRoute(
        builder: (context) => AuthWrapper(
          authenticatedChild: ImagePreviewPage(imageSource: source),
        ),
      );
    }
    if (settings.name != null && settings.name!.startsWith('$docsModelBase/')) {
      final modelName = settings.name!.substring('$docsModelBase/'.length);
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
    return null;
  }
}
