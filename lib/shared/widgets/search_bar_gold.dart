import 'package:flutter/material.dart';
import 'glass_card.dart';
import 'package:quranaudio/core/theme/app_spacing.dart';
import 'package:quranaudio/core/theme/app_typography.dart';

/// A search bar with glassmorphism styling, gold border, and integrated TextField.
///
/// Features:
/// - 48px height
/// - Dark gradient background
/// - 0.5px gold border (19% opacity)
/// - 14px border radius
/// - 10px backdrop blur
/// - White text, gray placeholder
class SearchBarGold extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  const SearchBarGold({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onTap,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: searchBarRadius,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SizedBox(
        height: searchBarHeight,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onTap: onTap,
          onChanged: onChanged,
          style: searchInput,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: searchPlaceholder,
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.only(top: 12, bottom: 12),
          ),
        ),
      ),
    );
  }
}
