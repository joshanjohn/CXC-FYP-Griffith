import 'package:flutter/material.dart';
import 'package:frontend/app/routes.dart';
import 'package:frontend/app/themes/app_colors.dart';
import 'package:frontend/features/docs/controllers/docs_controller.dart';
import 'package:frontend/features/docs/models/model_info.dart';
import 'package:frontend/features/docs/view/widgets/model_info_image_panel.dart';
import 'package:frontend/features/docs/view/widgets/model_info_stat_card.dart';
import 'package:frontend/shared/responsive/responsive_helper.dart';
import 'package:frontend/shared/widgets/persistent_top_nav.dart';

class ModelInfoDetailPage extends StatefulWidget {
  const ModelInfoDetailPage({super.key, required this.modelName});

  final String modelName;

  @override
  State<ModelInfoDetailPage> createState() => ModelInfoDetailPageState();
}

class ModelInfoDetailPageState extends State<ModelInfoDetailPage> {
  final DocsController docsController = DocsController();
  late final Future<ModelInfo?> modelFuture;

  @override
  void initState() {
    super.initState();
    modelFuture = docsController.getModelInfoByName(widget.modelName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.12),
                                  AppColors.primaryDark.withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  modelInfo.name.toUpperCase(),
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  modelInfo.description,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.78),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: [
                                    ModelInfoStatCard(
                                      label: 'Model Accuracy',
                                      value: modelInfo.modelAccuracy
                                          .toStringAsFixed(2),
                                    ),
                                    ModelInfoStatCard(
                                      label: 'Validation Accuracy',
                                      value: modelInfo.valAccuracy
                                          .toStringAsFixed(2),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final twoColumns = constraints.maxWidth >= 900;
                              final panels = [
                                ModelInfoImagePanel(
                                  title: 'Test Confusion Matrix',
                                  assetPath: modelInfo.testConfusionImg,
                                ),
                                ModelInfoImagePanel(
                                  title: 'Test ROC Curve',
                                  assetPath: modelInfo.testRocImg,
                                ),
                                ModelInfoImagePanel(
                                  title: 'Validation Confusion Matrix',
                                  assetPath: modelInfo.valConfusionImg,
                                ),
                                ModelInfoImagePanel(
                                  title: 'Validation ROC Curve',
                                  assetPath: modelInfo.valRocImg,
                                ),
                              ];

                              if (!twoColumns) {
                                return Column(
                                  children: [
                                    for (final panel in panels) ...[
                                      panel,
                                      const SizedBox(height: 20),
                                    ],
                                  ],
                                );
                              }

                              return Wrap(
                                spacing: 20,
                                runSpacing: 20,
                                children: panels
                                    .map(
                                      (panel) => SizedBox(
                                        width: (constraints.maxWidth - 20) / 2,
                                        child: panel,
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
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
