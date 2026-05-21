import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/player_persistence.dart';

abstract class PlayerLocalDataSource {
  Future<PlayerPersistence?> getLastPlayerState();
  Future<void> savePlayerState(PlayerPersistence state);
  Future<void> clearPlayerState();
}

class PlayerLocalDataSourceImpl implements PlayerLocalDataSource {
  static const _key = 'ql_player_state';

  @override
  Future<PlayerPersistence?> getLastPlayerState() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return null;
    return PlayerPersistence.fromJson(
      Map<String, dynamic>.from(jsonDecode(json)),
    );
  }

  @override
  Future<void> savePlayerState(PlayerPersistence state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }

  @override
  Future<void> clearPlayerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
