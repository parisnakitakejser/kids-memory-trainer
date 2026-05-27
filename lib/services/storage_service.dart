import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreEntry {
  final String playerName;
  final int score;
  final int timeInSeconds;
  final String mode; // 'single' or 'multi'

  ScoreEntry({
    required this.playerName,
    required this.score,
    required this.timeInSeconds,
    required this.mode,
  });

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'score': score,
        'timeInSeconds': timeInSeconds,
        'mode': mode,
      };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
        playerName: json['playerName'],
        score: json['score'],
        timeInSeconds: json['timeInSeconds'],
        mode: json['mode'],
      );
}

class StorageService {
  static const String _scoresKey = 'memory_game_scores';

  Future<void> saveScore(ScoreEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> scoresJson = prefs.getStringList(_scoresKey) ?? [];
    scoresJson.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_scoresKey, scoresJson);
  }

  Future<List<ScoreEntry>> getScores(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> scoresJson = prefs.getStringList(_scoresKey) ?? [];
    List<ScoreEntry> allScores = scoresJson
        .map((jsonStr) => ScoreEntry.fromJson(jsonDecode(jsonStr)))
        .toList();

    List<ScoreEntry> filtered =
        allScores.where((entry) => entry.mode == mode).toList();

    if (mode == 'single') {
      // For single player, lower time is better
      filtered.sort((a, b) => a.timeInSeconds.compareTo(b.timeInSeconds));
    } else {
      // For multiplayer, higher score is better
      filtered.sort((a, b) => b.score.compareTo(a.score));
    }

    return filtered;
  }
}
