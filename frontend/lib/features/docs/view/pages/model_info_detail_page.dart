import 'package:flutter/material.dart';
import 'package:cxc/app/routes.dart';
import 'package:cxc/features/docs/controllers/docs_controller.dart';
import 'package:cxc/features/docs/models/model_info.dart';
import 'package:cxc/features/docs/view/widgets/model_info_detail_header.dart';
import 'package:cxc/features/docs/view/widgets/model_info_image_section.dart';
import 'package:cxc/shared/responsive/responsive_helper.dart';
import 'package:cxc/shared/widgets/persistent_top_nav.dart';

class ModelInfoDetailPage extends StatefulWidget {
  const ModelInfoDetailPage({
    super.key,
    required this.modelName,
    this.initialModelInfo,
  });

  final String modelName;
  final ModelInfo? initialModelInfo;

  @override
  State<ModelInfoDetailPage> createState() => ModelInfoDetailPageState();
}

class ModelInfoDetailPageState extends State<ModelInfoDetailPage> {
  final DocsController docsController = DocsController();
  late final Future<ModelInfo?> modelFuture;

  void handleBackNavigation() {
    // Get the current navigator instance
    final navigator = Navigator.of(context);

    // Return to the previous screen if possible
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    // Navigate to the documentation screen if no previous route exists
    navigator.pushReplacementNamed(AppRoutes.docs);
  }

  @override
  void initState() {
    super.initState();

    // Load model information when the screen is created
    modelFuture = docsController.getModelInfoByName(
      widget.modelName,

      // Use provided model data before fetching from cache or API
      fallback: widget.initialModelInfo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final showCameraItem = ResponsiveHelper.isPlatformMobile();

    return Scaffold(
      body: Column(
        children: [
          PersistentTopNav(
            items: [
              PersistentTopNavItem(
                label: 'Home',
                icon: Icons.home_rounded,
                isActive: false,
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.workspace,
                ),
              ),
              if (showCameraItem)
                PersistentTopNavItem(
                  label: 'Camera',
                  icon: Icons.camera_alt_rounded,
                  isActive: false,
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.workspace,
                  ),
                ),
              PersistentTopNavItem(
                label: 'Batch',
                icon: Icons.layers_rounded,
                isActive: false,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.batch),
              ),
              PersistentTopNavItem(
                label: 'Docs',
                icon: Icons.library_books_rounded,
                isActive: true,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.docs),
              ),
              PersistentTopNavItem(
                label: 'Profile',
                icon: Icons.person_rounded,
                isActive: false,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.profile),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<ModelInfo?>(
              future: modelFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load model detail: ${snapshot.error}',
                    ),
                  );
                }

                final modelInfo = snapshot.data;
                if (modelInfo == null) {
                  return Center(
                    child: Text(
                      'No documentation found for ${widget.modelName}.',
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            onPressed: handleBackNavigation,
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Back'),
                          ),
                          const SizedBox(height: 16),
                          ModelInfoDetailHeader(modelInfo: modelInfo),
                          const SizedBox(height: 28),
                          ModelInfoImageSection(modelInfo: modelInfo),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
