import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/surah.dart';

/// Card widget displaying a surah in the list
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
                  color: AppTheme.lavender,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    surah.surahId,
                    style: const TextStyle(
                      color: AppTheme.darkText,
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
                            style: const TextStyle(
                              color: AppTheme.darkText,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentPurple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${surah.ayahCount} ayahs',
                            style: const TextStyle(
                              color: AppTheme.accentPurple,
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
                      style: const TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      surah.name,
                      style: const TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 12,
                        fontFamily: 'Amiri', // Would need to add Arabic font
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation arrow
              const Icon(
                Icons.chevron_right,
                color: AppTheme.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
