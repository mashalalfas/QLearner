import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/player/providers/player_auto_save_provider.dart';

/// App lifecycle listener — saves player state when app goes to background.
class _QLearnerAppState extends State<QLearnerApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Trigger immediate save
      try {
        final container = ProviderScope.containerOf(context);
        container.read(playerAutoSaveProvider.notifier).saveNow();
      } catch (e) {
        // Silent fail — app is backgrounding
      }
    }
    super.didChangeAppLifecycleState(state);
  }
}
