import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: _buildImage(theme),
      ),
    );
  }

  Widget _buildImage(ThemeData theme) {
    if (kIsWeb) {
      // Web: handle network or local file
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
      // Mobile/Desktop: handle File
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
      color: theme.colorScheme.errorContainer,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load image',
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
