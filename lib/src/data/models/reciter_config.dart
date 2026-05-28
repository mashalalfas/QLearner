/// Map of Surah number (1-114) to URL-safe slug for the AllahsWord reciter.
///
/// URL format: {baseAudioUrl}/{number}_{surah_name}.mp3
///
/// Slug entries are provided in lowercase (Archive.org is case-insensitive, but
/// these match the actual Archive.org filenames exactly).
const Map<int, String> allahsWordSurahSlugs = {
  // 1
  1: '001 Surah Al Fatihah',
  // 2
  2: '002 Surah Al Baqarah',
  // 3
  3: '003 Surah Al Imran',
  // 4
  4: '004 Surah An Nisa',
  // 5
  5: '005 Surah Al Maidah',
  // 6
  6: '006 Surah Al Anam',
  // 7
  7: '007 Surah Al Araf',
  // 8
  8: '008 Surah Al Anfal',
  // 9
  9: '009 Surah At Tawbah',
  // 10
  10: '010 Surah Yunus',
  // 11
  11: '011 Surah Hud',
  // 12
  12: '012 Surah Yusuf',
  // 13
  13: '013 Surah Ar Rad',
  // 14
  14: '014 Surah Ibrahim',
  // 15
  15: '015 Surah Al Hijr',
  // 16
  16: '016 Surah An Nahl',
  // 17
  17: '017 Surah Al Isra',
  // 18
  18: '018 Surah Al Kahf',
  // 19
  19: '019 Surah Maryam',
  // 20
  20: '020 Surah Ta Ha',
  // 21
  21: '021 Surah Al Anbiya',
  // 22
  22: '022 Surah Al Hajj',
  // 23
  23: '023 Surah Al Muminun',
  // 24
  24: '024 Surah An Nur',
  // 25
  25: '025 Surah Al Furqan',
  // 26
  26: '026 Surah Ash Shuara',
  // 27
  27: '027 Surah An Naml',
  // 28
  28: '028 Surah Al Qasas',
  // 29
  29: '029 Surah Al Ankabut',
  // 30
  30: '030 Surah Ar Rum',
  // 31
  31: '031 Surah Luqman',
  // 32
  32: '032 Surah As Sajdah',
  // 33
  33: '033 Surah Al Ahzab',
  // 34
  34: '034 Surah Saba',
  // 35
  35: '035 Surah Fatir',
  // 36
  36: '036 Surah Ya Sin',
  // 37
  37: '037 Surah As Saffat',
  // 38
  38: '038 Surah Sad',
  // 39
  39: '039 Surah Az Zumar',
  // 40
  40: '040 Surah Ghafir',
  // 41
  41: '041 Surah Fussilat',
  // 42
  42: '042 Surah Ash Shura',
  // 43
  43: '043 Surah Az Zukhruf',
  // 44
  44: '044 Surah Ad Dukhan',
  // 45
  45: '045 Surah Al Jathiyah',
  // 46
  46: '046 Surah Al Ahqaf',
  // 47
  47: '047 Surah Muhammad',
  // 48
  48: '048 Surah Al Fath',
  // 49
  49: '049 Surah Al Hujurat',
  // 50
  50: '050 Surah Qaf',
  // 51
  51: '051 Surah Adh Dhariyat',
  // 52
  52: '052 Surah At Tur',
  // 53
  53: '053 Surah An Najm',
  // 54
  54: '054 Surah Al Qamar',
  // 55
  55: '055 Surah Ar Rahman',
  // 56
  56: '056 Surah Al Waqiah',
  // 57
  57: '057 Surah Al Hadid',
  // 58
  58: '058 Surah Al Mujadila',
  // 59
  59: '059 Surah Al Hashr',
  // 60
  60: '060 Surah Al Mumtahinah',
  // 61
  61: '061 Surah As Saff',
  // 62
  62: '062 Surah Al Jumuah',
  // 63
  63: '063 Surah Al Munafiqun',
  // 64
  64: '064 Surah At Taghabun',
  // 65
  65: '065 Surah At Talaq',
  // 66
  66: '066 Surah At Tahrim',
  // 67
  67: '067 Surah Al Mulk',
  // 68
  68: '068 Surah Al Qalam',
  // 69
  69: '069 Surah Al Haqqah',
  // 70
  70: '070 Surah Al Maarij',
  // 71
  71: '071 Surah Nuh',
  // 72
  72: '072 Surah Al Jinn',
  // 73
  73: '073 Surah Al Muzzammil',
  // 74
  74: '074 Surah Al Muddathir',
  // 75
  75: '075 Surah Al Qiyamah',
  // 76
  76: '076 Surah Al Insan',
  // 77
  77: '077 Surah Al Mursalat',
  // 78
  78: '078 Surah An Naba',
  // 79
  79: '079 Surah An Naziat',
  // 80
  80: '080 Surah Abasa',
  // 81
  81: '081 Surah At Takwir',
  // 82
  82: '082 Surah Al Infitar',
  // 83
  83: '083 Surah Al Mutaffifin',
  // 84
  84: '084 Surah Al Inshiqaq',
  // 85
  85: '085 Surah Al Buruj',
  // 86
  86: '086 Surah At Tariq',
  // 87
  87: '087 Surah Al Ala',
  // 88
  88: '088 Surah Al Ghashiyah',
  // 89
  89: '089 Surah Al Fajr',
  // 90
  90: '090 Surah Al Balad',
  // 91
  91: '091 Surah Ash Shams',
  // 92
  92: '092 Surah Al Layl',
  // 93
  93: '093 Surah Ad Duha',
  // 94
  94: '094 Surah Al Sharh',
  // 95
  95: '095 Surah At Tin',
  // 96
  96: '096 Surah Al Alaq',
  // 97
  97: '097 Surah Al Qadr',
  // 98
  98: '098 Surah Al Bayyinah',
  // 99
  99: '099 Surah Az Zalzalah',
  // 100
  100: '100 Surah Al Adiyat',
  // 101
  101: '101 Surah Al Qariah',
  // 102
  102: '102 Surah At Takathur',
  // 103
  103: '103 Surah Al Asr',
  // 104
  104: '104 Surah Al Humazah',
  // 105
  105: '105 Surah Al Fil',
  // 106
  106: '106 Surah Quraysh',
  // 107
  107: '107 Surah Al Maun',
  // 108
  108: '108 Surah Al Kawthar',
  // 109
  109: '109 Surah Al Kafirun',
  // 110
  110: '110 Surah An Nasr',
  // 111
  111: '111 Surah Al Lahab',
  // 112
  112: '112 Surah Al Ikhlas',
  // 113
  113: '113 Surah Al Falaq',
  // 114
  114: '114 Surah An Nas',
};

/// Returns the URL-safe slug for [surahNumber] in the AllahsWord Archive.org
/// audio collection, or null if the number is out of range.
String? getAllahsWordSlug(int surahNumber) {
  return allahsWordSurahSlugs[surahNumber];
}
