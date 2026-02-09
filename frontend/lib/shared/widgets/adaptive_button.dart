import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Adaptive button widget with platform-specific styling
class AdaptiveButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isPrimary;
  final double? width;
  final double? height;

  const AdaptiveButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isPrimary = true,
    this.width,
    this.height,
  });

  @override
  State<AdaptiveButton> createState() => _AdaptiveButtonState();
}

class _AdaptiveButtonState extends State<AdaptiveButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.fastAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: AppConstants.fastAnimation,
            width: widget.width,
            height: widget.height ?? 56,
            decoration: BoxDecoration(
              gradient: widget.isPrimary
                  ? const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.isPrimary
                  ? null
                  : (theme.brightness == Brightness.dark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: widget.isPrimary
                  ? null
                  : Border.all(
                      color: AppColors.outlineLight.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
              boxShadow: [
                BoxShadow(
                  color: widget.isPrimary
                      ? AppColors.primary.withValues(alpha: _isHovered ? 0.4 : 0.2)
                      : Colors.black.withValues(alpha: _isHovered ? 0.1 : 0.05),
                  blurRadius: _isHovered ? 20 : 12,
                  offset: Offset(0, _isHovered ? 8 : 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading ? null : widget.onPressed,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      else ...[
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: widget.isPrimary
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          widget.text,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: widget.isPrimary
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
