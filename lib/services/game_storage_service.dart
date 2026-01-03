import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../game_state.dart';

class GameStorageService {
  static const String _storageKeyPrefix = 'saved_game_state_';
  static const String _metadataKey = 'save_slots_metadata';

  // Check if a save exists in a specific slot
  Future<bool> hasSaveGame(int slotId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('${_storageKeyPrefix}$slotId');
  }

  // Save the current game state to a specific slot
  Future<void> saveGame(GameState gameState, int slotId,
      {String? saveName}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(gameState.toJson());

    // Save game data
    await prefs.setString('${_storageKeyPrefix}$slotId', jsonString);

    // Update metadata
    await _updateSlotMetadata(slotId, gameState, customName: saveName);
  }

  // Load the game state from a specific slot
  Future<Map<String, dynamic>?> loadGame(int slotId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('${_storageKeyPrefix}$slotId');

    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding save file: $e');
      return null;
    }
  }

  // Get metadata for all slots (for displaying in the UI)
  Future<Map<int, SaveSlotMetadata>> getSlotsMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_metadataKey);

    if (jsonString == null) return {};

    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      return data.map((key, value) => MapEntry(
            int.parse(key),
            SaveSlotMetadata.fromJson(value),
          ));
    } catch (e) {
      print('Error decoding metadata: $e');
      return {};
    }
  }

  // Clear a specific slot
  Future<void> clearSlot(int slotId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_storageKeyPrefix}$slotId');
    await _removeSlotMetadata(slotId);
  }

  // Rename a save slot
  Future<void> renameSave(int slotId, String newName) async {
    final prefs = await SharedPreferences.getInstance();
    final metadata = await getSlotsMetadata();

    if (metadata.containsKey(slotId)) {
      metadata[slotId] = metadata[slotId]!.copyWith(saveName: newName);
      final jsonMap = metadata
          .map((key, value) => MapEntry(key.toString(), value.toJson()));
      await prefs.setString(_metadataKey, jsonEncode(jsonMap));
    }
  }

  // Private helper to update metadata
  Future<void> _updateSlotMetadata(int slotId, GameState gameState,
      {String? customName}) async {
    final prefs = await SharedPreferences.getInstance();
    final metadata = await getSlotsMetadata();

    // Use custom name if provided, otherwise use existing name or default
    final existingMetadata = metadata[slotId];
    final saveName = customName ?? existingMetadata?.saveName ?? 'حفظ $slotId';

    metadata[slotId] = SaveSlotMetadata(
      saveName: saveName,
      lastPlayed: DateTime.now(),
      teamCount: gameState.teams.length,
      countryCount: gameState.countries.length,
      turnCount:
          gameState.currentTeamIndex, // Using this as proxy for turns/progress
    );

    final jsonMap =
        metadata.map((key, value) => MapEntry(key.toString(), value.toJson()));
    await prefs.setString(_metadataKey, jsonEncode(jsonMap));
  }

  Future<void> _removeSlotMetadata(int slotId) async {
    final prefs = await SharedPreferences.getInstance();
    final metadata = await getSlotsMetadata();
    metadata.remove(slotId);

    final jsonMap =
        metadata.map((key, value) => MapEntry(key.toString(), value.toJson()));
    await prefs.setString(_metadataKey, jsonEncode(jsonMap));
  }
}

class SaveSlotMetadata {
  final String saveName;
  final DateTime lastPlayed;
  final int teamCount;
  final int countryCount;
  final int turnCount;

  SaveSlotMetadata({
    required this.saveName,
    required this.lastPlayed,
    required this.teamCount,
    required this.countryCount,
    required this.turnCount,
  });

  Map<String, dynamic> toJson() => {
        'saveName': saveName,
        'lastPlayed': lastPlayed.toIso8601String(),
        'teamCount': teamCount,
        'countryCount': countryCount,
        'turnCount': turnCount,
      };

  factory SaveSlotMetadata.fromJson(Map<String, dynamic> json) {
    return SaveSlotMetadata(
      saveName: json['saveName'] ?? 'حفظ',
      lastPlayed: DateTime.parse(json['lastPlayed']),
      teamCount: json['teamCount'],
      countryCount: json['countryCount'],
      turnCount: json['turnCount'],
    );
  }

  SaveSlotMetadata copyWith({String? saveName}) {
    return SaveSlotMetadata(
      saveName: saveName ?? this.saveName,
      lastPlayed: lastPlayed,
      teamCount: teamCount,
      countryCount: countryCount,
      turnCount: turnCount,
    );
  }
}
