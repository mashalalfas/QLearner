import 'package:flutter/material.dart';
import '../../core/theme/cotton_cloud_theme.dart';

/// Reusable Glass Card Widget
/// A card with frosted glass effect, hairline border, and subtle shadow
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;
  final Border? border;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.color,
    this.padding,
    this.margin,
    this.onTap,
    this.shadows,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? CottonCloudTheme.glassWhite,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ?? CottonCloudTheme.glassShadow,
        border: border ??
            Border.all(
              color: CottonCloudTheme.hairlineBorder,
              width: 0.5,
            ),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: widget,
      );
    }

    return widget;
  }
}

/// Compact Glass Card variant for list items
class GlassListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double borderRadius;

  const GlassListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding,
    this.onTap,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> rowChildren = [];

    if (leading != null) {
      rowChildren.addAll([
        leading!,
        const SizedBox(width: 12),
      ]);
    }

    rowChildren.add(
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTextStyle.merge(
              style: const TextStyle(
                color: CottonCloudTheme.text,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              child: title,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              DefaultTextStyle.merge(
                style: const TextStyle(
                  color: CottonCloudTheme.textSecondary,
                  fontSize: 13,
                ),
                child: subtitle!,
              ),
            ],
          ],
        ),
      ),
    );

    if (trailing != null) {
      rowChildren.addAll([
        const SizedBox(width: 8),
        trailing!,
      ]);
    }

    final content = Row(
      children: rowChildren,
    );

    return GlassCard(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: borderRadius,
      margin: const EdgeInsets.only(bottom: 8),
      onTap: onTap,
      child: content,
    );
  }
}
