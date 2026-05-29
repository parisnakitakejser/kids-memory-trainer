import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreEntry {
  static const topScoreLimit = 25;

  final String playerName;
  final int score;
  final int timeInSeconds;
  final int tries;
  final double successRatio;
  final String mode; // 'single' or 'multi'
  final String theme;
  final String? languageCode;

  ScoreEntry({
    required this.playerName,
    required this.score,
    required this.timeInSeconds,
    required this.tries,
    required this.successRatio,
    required this.mode,
    required this.theme,
    this.languageCode,
  });

  ScoreEntry copyWith({
    String? playerName,
  }) {
    return ScoreEntry(
      playerName: playerName ?? this.playerName,
      score: score,
      timeInSeconds: timeInSeconds,
      tries: tries,
      successRatio: successRatio,
      mode: mode,
      theme: theme,
      languageCode: languageCode,
    );
  }

  double get scorer {
    final matchPoints = score * 100;
    final accuracyPoints = successRatio * 1000;
    final timePenalty = mode == 'single' ? timeInSeconds * 2 : 0;
    final tryPenalty = tries * 5;

    return matchPoints + accuracyPoints - timePenalty - tryPenalty;
  }

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'score': score,
        'timeInSeconds': timeInSeconds,
        'tries': tries,
        'successRatio': successRatio,
        'mode': mode,
        'theme': theme,
        'languageCode': languageCode,
      };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
        playerName: json['playerName'],
        score: json['score'],
        timeInSeconds: json['timeInSeconds'],
        tries: json['tries'] ?? 0,
        successRatio: (json['successRatio'] as num?)?.toDouble() ?? 0,
        mode: json['mode'],
        theme: json['theme'] ?? 'animals',
        languageCode: json['languageCode'],
      );
}

class StorageService {
  static const String _scoresKey = 'memory_game_scores';

  Future<void> saveScore(ScoreEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> scoresJson = prefs.getStringList(_scoresKey) ?? [];
    final allScores = scoresJson
        .map((jsonStr) => ScoreEntry.fromJson(jsonDecode(jsonStr)))
        .toList()
      ..add(entry);

    final trimmedScores = <ScoreEntry>[];
    final buckets = <String, List<ScoreEntry>>{};
    for (final score in allScores) {
      buckets.putIfAbsent(_bucketKey(score), () => []).add(score);
    }

    for (final bucket in buckets.values) {
      bucket.sort(_compareScores);
      trimmedScores.addAll(bucket.take(ScoreEntry.topScoreLimit));
    }

    await prefs.setStringList(
      _scoresKey,
      trimmedScores.map((score) => jsonEncode(score.toJson())).toList(),
    );
  }

  Future<bool> qualifiesForHighScore(ScoreEntry entry) async {
    final scores = await getScores(
      mode: entry.mode,
      theme: entry.theme,
      languageCode: entry.languageCode,
    );

    if (scores.length < ScoreEntry.topScoreLimit) return true;

    return _compareScores(entry, scores.last) < 0;
  }

  Future<List<ScoreEntry>> getScores({
    required String mode,
    required String theme,
    String? languageCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> scoresJson = prefs.getStringList(_scoresKey) ?? [];
    List<ScoreEntry> allScores = scoresJson
        .map((jsonStr) => ScoreEntry.fromJson(jsonDecode(jsonStr)))
        .toList();

    List<ScoreEntry> filtered = allScores.where((entry) {
      return entry.mode == mode &&
          entry.theme == theme &&
          (languageCode == null || entry.languageCode == languageCode);
    }).toList();

    filtered.sort(_compareScores);
    return filtered.take(ScoreEntry.topScoreLimit).toList();
  }

  int _compareScores(ScoreEntry a, ScoreEntry b) {
    final scorerCompare = b.scorer.compareTo(a.scorer);
    if (scorerCompare != 0) return scorerCompare;

    final scoreCompare = b.score.compareTo(a.score);
    if (scoreCompare != 0) return scoreCompare;

    final ratioCompare = b.successRatio.compareTo(a.successRatio);
    if (ratioCompare != 0) return ratioCompare;

    final triesCompare = a.tries.compareTo(b.tries);
    if (triesCompare != 0) return triesCompare;

    return a.timeInSeconds.compareTo(b.timeInSeconds);
  }

  String _bucketKey(ScoreEntry score) {
    return [
      score.mode,
      score.theme,
      score.languageCode ?? 'global',
    ].join(':');
  }
}
