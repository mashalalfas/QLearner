import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../providers/reciters_providers.dart';

/// Reciters Screen — Choose your preferred recitation style
///
/// Dignity theme: premium black & gold with glassmorphism cards
class RecitersScreen extends ConsumerWidget {
  const RecitersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reciters = ref.watch(recitersProvider);
    final selectedId = ref.watch(selectedReciterIdProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top spacing
            const SizedBox(height: screenPaddingTop),

            // Header section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: screenPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with gold underline
                  _GoldUnderlineTitle(title: 'Reciters'),
                  SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'Choose your preferred recitation style',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGray,
                      fontFamily: fontBody,
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),

            // Reciter list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: screenPaddingH),
                itemCount: reciters.length,
                itemBuilder: (context, index) {
                  final reciter = reciters[index];
                  final isSelected = reciter.id == selectedId;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReciterCard(
                      reciter: reciter,
                      isSelected: isSelected,
                      onSelect: () {
                        ref.read(selectedReciterIdProvider.notifier).state =
                            reciter.id;
                      },
                    ),
                  );
                },
              ),
            ),

            // Bottom spacing for navigation
            const SizedBox(height: screenPaddingBottom + 20),
          ],
        ),
      ),
    );
  }
}

/// Title widget with gold underline decoration
class _GoldUnderlineTitle extends StatelessWidget {
  final String title;

  const _GoldUnderlineTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textWhite,
            fontFamily: fontBody,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 60,
          height: 3,
          decoration: const BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
      ],
    );
  }
}

/// Individual reciter card with selection state
class _ReciterCard extends ConsumerWidget {
  final Reciter reciter;
  final bool isSelected;
  final VoidCallback onSelect;

  const _ReciterCard({
    required this.reciter,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      radius: 16,
      borderWidth: isSelected ? 1.0 : 0.5,
      padding: const EdgeInsets.symmetric(
        vertical: cardPaddingV,
        horizontal: cardPaddingH,
      ),
      child: Row(
        children: [
          // Reciter info (left side)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reciter name
                Text(
                  reciter.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                    fontFamily: fontBody,
                  ),
                ),
                const SizedBox(height: 4),
                // Style and region
                Text(
                  '${reciter.language} • ${reciter.style} • ${reciter.region}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.goldMuted,
                    fontFamily: fontBody,
                  ),
                ),
              ],
            ),
          ),

          // Select button (right side)
          const SizedBox(width: 12),
          _SelectButton(
            isSelected: isSelected,
            onTap: onSelect,
          ),
        ],
      ),
    );
  }
}

/// Select button with gold outline that fills with gold gradient when selected
class _SelectButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectButton({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.goldGradient : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.goldStart,
            width: 0.5,
          ),
        ),
        child: Text(
          isSelected ? 'Selected' : 'Select',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: AppColors.goldStart,
            fontFamily: fontBody,
          ),
        ),
      ),
    );
  }
}
