import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model representing a Quran reciter
class Reciter {
  final String id;
  final String name;
  final String language;
  final String style;
  final String region;

  const Reciter({
    required this.id,
    required this.name,
    required this.language,
    required this.style,
    required this.region,
  });
}

/// Provider for the list of available reciters (static data)
final recitersProvider = Provider<List<Reciter>>((ref) {
  return const [
    Reciter(
      id: 'mishary_rashid_alafasy',
      name: 'Mishary Rashid Alafasy',
      language: 'Arabic',
      style: 'Murattal',
      region: 'Kuwait',
    ),
    Reciter(
      id: 'abdul_basit_abdul_samad',
      name: 'Abdul Basit Abdul Samad',
      language: 'Arabic',
      style: 'Murattal',
      region: 'Egypt',
    ),
    Reciter(
      id: 'muhammad_siddiq_al_minshawi',
      name: 'Muhammad Siddiq Al-Minshawi',
      language: 'Arabic',
      style: 'Murattal',
      region: 'Egypt',
    ),
    Reciter(
      id: 'mahmoud_khalil_al_husary',
      name: 'Mahmoud Khalil Al-Husary',
      language: 'Arabic',
      style: 'Murattal',
      region: 'Egypt',
    ),
    Reciter(
      id: 'muhammad_ayyub',
      name: 'Muhammad Ayyub',
      language: 'Arabic',
      style: 'Murattal',
      region: 'Saudi Arabia',
    ),
    Reciter(
      id: 'saad_al_ghamdi',
      name: 'Saad Al-Ghamdi',
      language: 'Arabic',
      style: 'Murattal',
      region: 'Saudi Arabia',
    ),
    Reciter(
      id: 'yasser_al_dosari',
      name: 'Yasser Al-Dosari',
      language: 'Arabic',
      style: 'Murattal',
      region: 'Saudi Arabia',
    ),
    Reciter(
      id: 'saud_al_shuraim',
      name: 'Saud Al-Shuraim',
      language: 'Arabic',
      style: 'Murattal',
      region: 'Saudi Arabia',
    ),
  ];
});

/// Provider for the currently selected reciter ID
/// null means no reciter selected yet
final selectedReciterIdProvider = StateProvider<String?>((ref) => null);

/// Provider for the currently selected Reciter object (derived)
final selectedReciterProvider = Provider<Reciter?>((ref) {
  final selectedId = ref.watch(selectedReciterIdProvider);
  final reciters = ref.watch(recitersProvider);

  if (selectedId == null) return null;

  try {
    return reciters.firstWhere((r) => r.id == selectedId);
  } catch (e) {
    return null;
  }
});
