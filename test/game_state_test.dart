import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/models/game_state.dart';
import 'package:memory_game/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('counts tries and calculates success ratio', () async {
    final gameState = GameState(
      isMultiplayer: false,
      playerNames: const ['Player 1'],
      theme: GameTheme.letters,
      gridSize: 4,
    );

    const firstMatchIndex = 0;
    final firstMatchKey = gameState.cards[firstMatchIndex].matchKey;
    final secondMatchIndex = gameState.cards.indexWhere(
      (card) =>
          card.matchKey == firstMatchKey &&
          gameState.cards.indexOf(card) != firstMatchIndex,
    );

    gameState.flipCard(firstMatchIndex);
    gameState.flipCard(secondMatchIndex);

    expect(gameState.tries, 1);
    expect(gameState.matchedPairs, 1);
    expect(gameState.successRatio, 1);

    gameState.acknowledgeMatchPreview();

    final unmatchedIndexes = <int>[];
    for (var i = 0; i < gameState.cards.length; i++) {
      final card = gameState.cards[i];
      if (!card.isMatched &&
          unmatchedIndexes.every(
            (index) => gameState.cards[index].matchKey != card.matchKey,
          )) {
        unmatchedIndexes.add(i);
      }

      if (unmatchedIndexes.length == 2) break;
    }

    gameState.flipCard(unmatchedIndexes[0]);
    gameState.flipCard(unmatchedIndexes[1]);

    expect(gameState.tries, 2);
    expect(gameState.matchedPairs, 1);
    expect(gameState.successRatio, 0.5);

    await Future<void>.delayed(const Duration(milliseconds: 1100));
    gameState.dispose();
  });

  test('scorer ranks accurate games above faster inaccurate games', () {
    final fastInaccurate = ScoreEntry(
      playerName: 'Fast',
      score: 20,
      timeInSeconds: 30,
      tries: 100,
      successRatio: 0.2,
      mode: 'single',
      theme: 'animals',
    );
    final slowerAccurate = ScoreEntry(
      playerName: 'Accurate',
      score: 21,
      timeInSeconds: 35,
      tries: 70,
      successRatio: 0.3,
      mode: 'single',
      theme: 'animals',
    );

    expect(slowerAccurate.scorer, greaterThan(fastInaccurate.scorer));
  });

  test('stores only top 25 scores per board bucket', () async {
    SharedPreferences.setMockInitialValues({});

    final storage = StorageService();
    for (var i = 0; i < 30; i++) {
      await storage.saveScore(ScoreEntry(
        playerName: 'Player $i',
        score: i,
        timeInSeconds: 30,
        tries: 30 - i,
        successRatio: i / 30,
        mode: 'single',
        theme: 'animals',
      ));
    }

    final scores = await storage.getScores(
      mode: 'single',
      theme: 'animals',
    );

    expect(scores, hasLength(ScoreEntry.topScoreLimit));
    expect(scores.first.playerName, 'Player 29');
    expect(scores.last.playerName, 'Player 5');
  });

  test('randomizes asset order before creating pairs', () {
    final sortedAssets = List.generate(40, (index) => 'asset_$index.png');
    var foundDifferentOrder = false;

    for (var attempt = 0; attempt < 12; attempt++) {
      final gameState = GameState(
        isMultiplayer: false,
        playerNames: const ['Player 1'],
        theme: GameTheme.animals,
        gridSize: 4,
        themeAssets: sortedAssets,
      );
      final usedAssets = gameState.cards
          .map((card) => card.assetPath)
          .whereType<String>()
          .toSet()
          .toList();

      if (usedAssets.join('|') !=
          sortedAssets.take(usedAssets.length).join('|')) {
        foundDifferentOrder = true;
      }

      gameState.dispose();
      if (foundDifferentOrder) break;
    }

    expect(foundDifferentOrder, isTrue);
  });

  test('cancels game timer immediately when last pair matches', () async {
    final gameState = GameState(
      isMultiplayer: false,
      playerNames: const ['Player 1'],
      theme: GameTheme.letters,
      gridSize: 2,
    );

    final groups = <String, List<int>>{};
    for (var i = 0; i < gameState.cards.length; i++) {
      final key = gameState.cards[i].matchKey;
      groups.putIfAbsent(key, () => []).add(i);
    }

    final pairs = groups.values.toList();
    expect(pairs.length, 2);

    // Flip first pair
    gameState.flipCard(pairs[0][0]);
    gameState.flipCard(pairs[0][1]);
    expect(gameState.matchedPairs, 1);
    gameState.acknowledgeMatchPreview();

    final secondsBeforeLastMatch = gameState.elapsedSeconds;
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    final secondsAfterDelay = gameState.elapsedSeconds;
    expect(secondsAfterDelay, greaterThan(secondsBeforeLastMatch));

    // Flip last pair
    gameState.flipCard(pairs[1][0]);
    gameState.flipCard(pairs[1][1]);
    expect(gameState.matchedPairs, 2);

    final secondsOnMatch = gameState.elapsedSeconds;
    await Future<void>.delayed(const Duration(milliseconds: 1100));

    // Should NOT have incremented further because the timer is cancelled
    expect(gameState.elapsedSeconds, secondsOnMatch);

    gameState.dispose();
  });
}
