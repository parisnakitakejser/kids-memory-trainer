import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/models/game_state.dart';

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
}
