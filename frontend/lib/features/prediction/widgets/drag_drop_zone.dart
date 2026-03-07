import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../app/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// A premium drag-and-drop zone for desktop and web
class DragDropZone extends StatefulWidget {
  final Function(List<dynamic> files) onFilesDropped;
  final Widget child;
  final String label;
  final IconData icon;

  const DragDropZone({
    super.key,
    required this.onFilesDropped,
    required this.child,
    this.label = 'Drop X-Ray image here to analyze',
    this.icon = Icons.cloud_upload_outlined,
  });

  @override
  State<DragDropZone> createState() => _DragDropZoneState();
}

class _DragDropZoneState extends State<DragDropZone> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (details) => setState(() => _isDragging = true),
      onDragExited: (details) => setState(() => _isDragging = false),
      onDragDone: (details) {
        setState(() => _isDragging = false);
        if (details.files.isNotEmpty) {
          widget.onFilesDropped(details.files);
        }
      },
      child: Stack(
        children: [
          widget.child,
          if (_isDragging)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _isDragging ? 1.0 : 0.0,
                duration: AppConstants.fastAnimation,
                child: Container(
                  margin: const EdgeInsets.all(AppConstants.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusLarge,
                    ),
                  ),
                  child: DottedBorder(
                    color: AppColors.primary,
                    strokeWidth: 3,
                    dashPattern: const [10, 6],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(AppConstants.radiusLarge),
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(widget.icon, size: 64, color: AppColors.primary),
                          const SizedBox(height: 16),
                          Text(
                            widget.label,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
