import 'package:flutter/material.dart';
import 'package:quranaudio/core/theme/app_colors.dart';
import 'package:quranaudio/core/theme/app_typography.dart';

/// Threshold for showing the large download confirmation dialog (40 MB).
const int largeDownloadThresholdBytes = 40 * 1024 * 1024; // 40 MB

/// Shows a confirmation dialog when a file size exceeds 40 MB.
///
/// [sizeMB] is the file size in megabytes (already computed from bytes).
/// Returns `true` if the user taps "Download", `false` if "Cancel" or dismissed.
Future<bool> showLargeDownloadDialog(BuildContext context, double sizeMB) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.bgCardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.goldSoft, width: 0.5),
      ),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.goldStart, size: 24),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Large Download',
              style: TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w600,
                fontFamily: fontBody,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        'This surah is ${sizeMB.toStringAsFixed(1)} MB. Download over mobile data?',
        style: const TextStyle(
          color: AppColors.textGray,
          fontFamily: fontBody,
          fontSize: 14,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: AppColors.textGray,
              fontFamily: fontBody,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text(
            'Download',
            style: TextStyle(
              color: AppColors.goldStart,
              fontFamily: fontBody,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
