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
}
