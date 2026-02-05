import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Widget for displaying images responsively across different screen sizes
class ImageDisplayWidget extends StatelessWidget {
  final dynamic imageSource; // Can be XFile, File, or String path
  final double? maxHeight;
  final double? maxWidth;
  final BoxFit fit;

  const ImageDisplayWidget({
    super.key,
    required this.imageSource,
    this.maxHeight,
    this.maxWidth,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    // Calculate responsive dimensions
    final displayHeight = maxHeight ?? screenSize.height * 0.6;
    final displayWidth = maxWidth ?? screenSize.width * 0.9;

    return Container(
      constraints: BoxConstraints(
        maxHeight: displayHeight,
        maxWidth: displayWidth,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: _buildImage(theme),
      ),
    );
  }

  Widget _buildImage(ThemeData theme) {
    if (imageSource is Uint8List) {
      // Memory: used for Web or whenever raw bytes are provided
      return Image.memory(
        imageSource,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(theme),
      );
    }

    if (kIsWeb) {
      // Web: handle network or local blob URLs (if passed as string)
      if (imageSource is String) {
        return Image.network(
          imageSource,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget(theme);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingWidget();
          },
        );
      }
    } else {
      // Mobile/Desktop: handle File or path strings
      if (imageSource is File) {
        return Image.file(
          imageSource,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget(theme);
          },
        );
      } else if (imageSource is String) {
        return Image.file(
          File(imageSource),
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget(theme);
          },
        );
      }
    }

    return _buildErrorWidget(theme);
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Container(
      color: AppColors.error.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load image',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
