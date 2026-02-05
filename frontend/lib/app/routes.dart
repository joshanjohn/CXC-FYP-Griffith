import 'package:flutter/material.dart';
import '../features/analysis/presentation/pages/workspace_page.dart';
import '../features/analysis/presentation/pages/image_preview_page.dart';
import '../features/analysis/presentation/pages/permission_error_page.dart';

class AppRoutes {
  static const String initial = '/';
  static const String workspace = '/workspace';
  static const String preview = '/preview';
  static const String error = '/error';

  static Map<String, WidgetBuilder> get routes => {
    initial: (context) =>
        const WorkspacePage(), // Assuming WorkspacePage is now the entry
    workspace: (context) => const WorkspacePage(),
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
    return null;
  }
}
