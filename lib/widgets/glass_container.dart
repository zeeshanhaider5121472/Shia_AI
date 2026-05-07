import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: child,
    );

    if (margin != null) content = Container(margin: margin, child: content);
    if (onTap != null) content = GestureDetector(onTap: onTap, child: content);
    return content;
  }
}
