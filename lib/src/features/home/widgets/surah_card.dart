import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../data/models/surah.dart';

/// Card widget displaying a surah in the list
/// Dignity theme: dark background, gold accents
class SurahCard extends StatelessWidget {
  final Surah surah;
  final VoidCallback? onTap;

  const SurahCard({
    super.key,
    required this.surah,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: AppColors.bgCardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AppColors.goldSoft,
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Surah number circle
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.goldStart,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    surah.surahId,
                    style: const TextStyle(
                      color: AppColors.bgBase,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Surah info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            surah.englishName,
                            style: cardTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldStart.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${surah.ayahCount} ayahs',
                            style: const TextStyle(
                              color: AppColors.goldMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      surah.englishNameTranslation,
                      style: cardSubtitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      surah.name,
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 12,
                        fontFamily: 'Amiri',
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation arrow
              const Icon(
                Icons.chevron_right,
                color: AppColors.textGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
