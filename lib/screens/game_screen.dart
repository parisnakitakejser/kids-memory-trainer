import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../app_settings.dart';
import '../l10n/app_strings.dart';
import '../models/game_state.dart';
import '../widgets/memory_card.dart';
import '../services/storage_service.dart';
import '../services/theme_asset_service.dart';

class GameScreen extends StatefulWidget {
  final bool isMultiplayer;
  final List<String> playerNames;
  final GameTheme theme;
  final int gridSize;

  const GameScreen({
    super.key,
    required this.isMultiplayer,
    required this.playerNames,
    required this.theme,
    required this.gridSize,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameState? _gameState;
  final StorageService _storageService = StorageService();
  late int _activeGridSize;
  bool _gameOverHandled = false;

  @override
  void initState() {
    super.initState();
    _activeGridSize = widget.gridSize;
    _loadGame();
  }

  Future<void> _loadGame() async {
    final themeAssets =
        await ThemeAssetService.loadAssetsForTheme(widget.theme);
    if (!mounted) return;

    final gameState = GameState(
      isMultiplayer: widget.isMultiplayer,
      playerNames: widget.playerNames,
      theme: widget.theme,
      gridSize: _activeGridSize,
      themeAssets: themeAssets,
    );
    gameState.addListener(_onGameStateChanged);

    final previousGameState = _gameState;
    previousGameState?.removeListener(_onGameStateChanged);
    previousGameState?.dispose();

    setState(() {
      _gameState = gameState;
      _gameOverHandled = false;
    });
  }

  @override
  void dispose() {
    _gameState?.removeListener(_onGameStateChanged);
    _gameState?.dispose();
    super.dispose();
  }

  void _onGameStateChanged() {
    final gameState = _gameState;
    if (gameState == null) return;

    if (gameState.isGameOver && !_gameOverHandled) {
      _gameOverHandled = true;
      _handleGameOver();
    }
    setState(() {});
  }

  Future<void> _handleGameOver() async {
    final gameState = _gameState;
    if (gameState == null) return;
    final strings = AppStrings.of(context);

    if (widget.isMultiplayer) {
      final winner =
          gameState.players.reduce((a, b) => a.score > b.score ? a : b);
      await _storageService.saveScore(ScoreEntry(
        playerName: winner.name,
        score: winner.score,
        timeInSeconds: 0,
        mode: 'multi',
      ));
    } else {
      await _storageService.saveScore(ScoreEntry(
        playerName: 'Player 1',
        score: gameState.matchedPairs,
        timeInSeconds: gameState.elapsedSeconds,
        mode: 'single',
      ));
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(strings.gameOver,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        content: Text(
          widget.isMultiplayer
              ? strings.winner(gameState.players
                  .reduce((a, b) => a.score > b.score ? a : b)
                  .name)
              : strings.completedIn(gameState.elapsedSeconds),
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(strings.mainMenu, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _showSettings() async {
    final settings = AppSettingsScope.of(context);
    var selectedLanguage = settings.language;
    var selectedGridSize = _activeGridSize;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final strings = AppStrings.of(context);

            return AlertDialog(
              title: Text(strings.gameSettings),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.languageLabel,
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<AppLanguage>(
                      initialValue: selectedLanguage,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.language),
                        labelText: strings.languageLabel,
                      ),
                      items: AppLanguage.values.map((language) {
                        return DropdownMenuItem(
                          value: language,
                          child: Text(language.label),
                        );
                      }).toList(),
                      onChanged: (language) {
                        if (language == null) return;
                        setDialogState(() {
                          selectedLanguage = language;
                        });
                      },
                    ),
                    const SizedBox(height: 22),
                    Text(strings.boardSize,
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 4, label: Text('4x4')),
                        ButtonSegment(value: 6, label: Text('6x6')),
                        ButtonSegment(value: 8, label: Text('8x8')),
                        ButtonSegment(value: 10, label: Text('10x10')),
                        ButtonSegment(value: 12, label: Text('12x12')),
                      ],
                      selected: {selectedGridSize},
                      onSelectionChanged: (newSelection) {
                        setDialogState(() {
                          selectedGridSize = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      strings.restartApplies,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(strings.cancel),
                ),
                FilledButton(
                  onPressed: () async {
                    await settings.setLanguage(selectedLanguage);

                    final shouldRestart = selectedGridSize != _activeGridSize;
                    if (shouldRestart) {
                      _activeGridSize = selectedGridSize;
                    }

                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }

                    if (shouldRestart && mounted) {
                      await _loadGame();
                    }
                  },
                  child: Text(strings.apply),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final gameState = _gameState;
    final strings = AppStrings.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7DA),
      appBar: AppBar(
        title: Text(widget.isMultiplayer
            ? strings.animalMatchParty
            : strings.animalTimeTrial),
        actions: [
          if (!widget.isMultiplayer)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  _formatTime(gameState?.elapsedSeconds ?? 0),
                  style: const TextStyle(
                    color: Color(0xFFFF7A59),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: strings.gameSettings,
            onPressed: _showSettings,
            icon: const Icon(Icons.settings),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: gameState == null
          ? const Center(child: CircularProgressIndicator())
          : _buildGameBody(context, gameState),
    );
  }

  Widget _buildGameBody(BuildContext context, GameState gameState) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF7DA),
            Color(0xFFE0F8FF),
            Color(0xFFFFE2EA),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useSideScoreboard = constraints.maxWidth >= 760;
            final scoreboard = _Scoreboard(
              gameState: gameState,
              isMultiplayer: widget.isMultiplayer,
            );
            final board = _FittedGameBoard(
              gameState: gameState,
              gridSize: _activeGridSize,
            );

            if (useSideScoreboard) {
              final scoreboardWidth =
                  (constraints.maxWidth * 0.3).clamp(240.0, 340.0);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: board),
                  const SizedBox(width: 18),
                  SizedBox(width: scoreboardWidth, child: scoreboard),
                ],
              );
            }

            return Column(
              children: [
                SizedBox(height: 146, child: scoreboard),
                const SizedBox(height: 14),
                Expanded(child: board),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FittedGameBoard extends StatelessWidget {
  final GameState gameState;
  final int gridSize;

  const _FittedGameBoard({
    required this.gameState,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.biggest.shortestSide;
        final spacing = boardSize < 360 ? 6.0 : 8.0;

        return Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22304A).withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox.square(
                dimension: boardSize - 24,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: gameState.cards.length,
                  itemBuilder: (context, index) {
                    return MemoryCard(
                      card: gameState.cards[index],
                      onTap: () => gameState.flipCard(index),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Scoreboard extends StatelessWidget {
  final GameState gameState;
  final bool isMultiplayer;

  const _Scoreboard({
    required this.gameState,
    required this.isMultiplayer,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22304A).withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: isMultiplayer
            ? _MultiplayerScores(gameState: gameState)
            : _SinglePlayerScores(gameState: gameState),
      ),
    );
  }
}

class _SinglePlayerScores extends StatelessWidget {
  final GameState gameState;

  const _SinglePlayerScores({required this.gameState});

  @override
  Widget build(BuildContext context) {
    final matchedCards = gameState.matchedPairPreviews;
    final strings = AppStrings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScoreHeader(
          title: strings.matches,
          score: '${gameState.matchedPairs}',
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _MatchedCardWrap(cards: matchedCards),
        ),
      ],
    );
  }
}

class _MultiplayerScores extends StatelessWidget {
  final GameState gameState;

  const _MultiplayerScores({required this.gameState});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 180;

        if (isCompact) {
          return Row(
            children: gameState.players.map((player) {
              return Expanded(
                child: _PlayerScorePanel(
                  player: player,
                  isCurrent: gameState.currentPlayer == player,
                  compact: true,
                ),
              );
            }).toList(),
          );
        }

        return Column(
          children: gameState.players.map((player) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: player == gameState.players.last ? 0 : 10,
                ),
                child: _PlayerScorePanel(
                  player: player,
                  isCurrent: gameState.currentPlayer == player,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _PlayerScorePanel extends StatelessWidget {
  final Player player;
  final bool isCurrent;
  final bool compact;

  const _PlayerScorePanel({
    required this.player,
    required this.isCurrent,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: EdgeInsets.symmetric(horizontal: compact ? 4 : 0),
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFFFF1A8) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent ? const Color(0xFFFFB84D) : const Color(0xFFBDD6FF),
          width: isCurrent ? 3 : 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScoreHeader(title: player.name, score: '${player.score}'),
          if (!compact) const SizedBox(height: 10),
          if (!compact)
            Expanded(child: _MatchedCardWrap(cards: player.matchedCards)),
        ],
      ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  final String title;
  final String score;

  const _ScoreHeader({
    required this.title,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(
              color: const Color(0xFF22304A),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          score,
          style: textTheme.headlineSmall?.copyWith(
            color: const Color(0xFFFF7A59),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _MatchedCardWrap extends StatelessWidget {
  final List<CardModel> cards;

  const _MatchedCardWrap({required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 6.0;
        const columns = 4;
        final rows = (cards.length / columns).ceil().clamp(1, 99);
        final widthSize =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final heightSize =
            (constraints.maxHeight - spacing * (rows - 1)) / rows;
        final tileSize = math.min(widthSize, heightSize).clamp(18.0, 48.0);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards.map((card) {
            return SizedBox.square(
              dimension: tileSize,
              child: _MatchedCardTile(card: card),
            );
          }).toList(),
        );
      },
    );
  }
}

class _MatchedCardTile extends StatelessWidget {
  final CardModel card;

  const _MatchedCardTile({required this.card});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: card.color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: card.assetPath != null
            ? Image.asset(
                card.assetPath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported_rounded,
                      color: Colors.white);
                },
              )
            : Center(
                child: Text(
                  card.content ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
      ),
    );
  }
}
