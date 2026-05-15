import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Font families
const String fontArabic = 'Noto Naskh Arabic';
const String fontBody = 'Plus Jakarta Sans';

/// Text styles (top-level constants)
const TextStyle appbarTitle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.5,
  color: AppColors.textWhite,
  fontFamily: fontBody,
);

const TextStyle surahArabic = TextStyle(
  fontFamily: fontArabic,
  fontSize: 20,
  fontWeight: FontWeight.w600,
  height: 1.4,
  color: AppColors.textWhite,
);

const TextStyle cardTitle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w600,
  color: AppColors.textWhite,
  fontFamily: fontBody,
);

const TextStyle cardSubtitle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: AppColors.textGray,
  fontFamily: fontBody,
);

const TextStyle metaText = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w500,
  color: AppColors.goldMuted,
  fontFamily: fontBody,
);

const TextStyle sectionHeader = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.5,
  color: AppColors.goldStart,
  fontFamily: fontBody,
);

const TextStyle navItem = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w600,
  letterSpacing: 1.0,
  color: AppColors.textWhite,
  fontFamily: fontBody,
);

const TextStyle playerSurahNumber = TextStyle(
  fontSize: 52,
  fontWeight: FontWeight.w700,
  fontFamily: fontBody,
);

const TextStyle playerArabic = TextStyle(
  fontFamily: fontArabic,
  fontSize: 28,
  fontWeight: FontWeight.w600,
  height: 1.4,
  color: AppColors.textWhite,
);

const TextStyle playerEnglish = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: AppColors.textWhite,
  fontFamily: fontBody,
);

const TextStyle searchInput = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w500,
  color: AppColors.textWhite,
  fontFamily: fontBody,
);

const TextStyle searchPlaceholder = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w500,
  color: AppColors.textGray,
  fontFamily: fontBody,
);

const TextStyle libraryItemTitle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w600,
  color: AppColors.textWhite,
  fontFamily: fontBody,
);

const TextStyle libraryItemMeta = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: AppColors.textGray,
  fontFamily: fontBody,
);

const TextStyle reciterName = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w600,
  color: AppColors.textWhite,
  fontFamily: fontBody,
);

const TextStyle reciterStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: AppColors.goldMuted,
  fontFamily: fontBody,
);

const TextStyle reciterButton = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.3,
  color: AppColors.goldStart,
  fontFamily: fontBody,
);
