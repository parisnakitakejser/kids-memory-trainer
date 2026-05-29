import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_settings.dart';
import '../l10n/app_strings.dart';
import '../models/game_state.dart';
import '../services/sound_service.dart';
import '../widgets/memory_card.dart';
import '../widgets/app_footer.dart';
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
  String? _lastMatchSoundCardId;
  bool _gameOverHandled = false;

  @override
  void initState() {
    super.initState();
    _activeGridSize = widget.gridSize;
    _loadGame();
  }

  Future<void> _loadGame() async {
    final language = AppSettingsScope.read(context).language;
    final themeAssets = await ThemeAssetService.loadAssetsForTheme(
      widget.theme,
      language: language,
    );
    if (!mounted) return;

    final gameState = GameState(
      isMultiplayer: widget.isMultiplayer,
      playerNames: widget.playerNames,
      theme: widget.theme,
      gridSize: _activeGridSize,
      themeAssets: themeAssets,
      fallbackLetters: language == AppLanguage.danish
          ? GameState.danishLetters
          : GameState.englishLetters,
    );
    gameState.addListener(_onGameStateChanged);

    final previousGameState = _gameState;
    previousGameState?.removeListener(_onGameStateChanged);
    previousGameState?.dispose();

    setState(() {
      _gameState = gameState;
      _lastMatchSoundCardId = null;
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

    final matchPreviewCard = gameState.matchPreviewCard;
    if (matchPreviewCard != null &&
        matchPreviewCard.id != _lastMatchSoundCardId) {
      _lastMatchSoundCardId = matchPreviewCard.id;
      SoundService.playMatch();
      HapticFeedback.mediumImpact();
    }

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

    if (widget.isMultiplayer) {
      final winner =
          gameState.players.reduce((a, b) => a.score > b.score ? a : b);
      SoundService.playWinnerApplause();
      HapticFeedback.heavyImpact();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _WinnerPortalDialog(
          winnerName: winner.name,
          scoreText: strings.winnerScore(winner.score),
          title: strings.winnerPortalTitle,
          mainMenuLabel: strings.mainMenu,
        ),
      );
      return;
    }

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
    final originalLanguage = settings.language;
    var selectedLanguage = originalLanguage;
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
                      showSelectedIcon: false,
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

                    final shouldRestart = selectedGridSize != _activeGridSize ||
                        (widget.theme == GameTheme.letters &&
                            selectedLanguage != originalLanguage);
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
          : Stack(
              children: [
                _buildGameBody(context, gameState),
                const Positioned(
                  left: 16,
                  bottom: 14,
                  child: AppFooter(),
                ),
                if (gameState.matchPreviewCard != null)
                  MatchCelebrationOverlay(
                    card: gameState.matchPreviewCard!,
                    title: strings.matchFound,
                    onDismiss: gameState.acknowledgeMatchPreview,
                  ),
              ],
            ),
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
        const SizedBox(height: 8),
        _ScoreStatsRow(
          stats: [
            _ScoreStat(label: strings.tries, value: '${gameState.tries}'),
            _ScoreStat(
                label: strings.ratio,
                value: _formatRatio(gameState.successRatio)),
          ],
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
          SizedBox(height: compact ? 6 : 8),
          _ScoreStatsRow(
            compact: compact,
            stats: [
              _ScoreStat(
                  label: AppStrings.of(context).tries,
                  value: '${player.tries}'),
              _ScoreStat(
                label: AppStrings.of(context).ratio,
                value: _formatRatio(player.successRatio),
              ),
            ],
          ),
          if (!compact) const SizedBox(height: 10),
          if (!compact)
            Expanded(child: _MatchedCardWrap(cards: player.matchedCards)),
        ],
      ),
    );
  }
}

class _ScoreStat {
  final String label;
  final String value;

  const _ScoreStat({required this.label, required this.value});
}

class _ScoreStatsRow extends StatelessWidget {
  final List<_ScoreStat> stats;
  final bool compact;

  const _ScoreStatsRow({
    required this.stats,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: compact ? 6 : 8,
      runSpacing: 6,
      children: stats.map((stat) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFA7E8FF).withValues(alpha: 0.36),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBDD6FF)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 7 : 9,
              vertical: compact ? 4 : 5,
            ),
            child: Text(
              '${stat.label}: ${stat.value}',
              style: textTheme.labelMedium?.copyWith(
                color: const Color(0xFF22304A),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

String _formatRatio(double ratio) => ratio.toStringAsFixed(1);

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

class MatchCelebrationOverlay extends StatefulWidget {
  final CardModel card;
  final String title;
  final VoidCallback onDismiss;

  const MatchCelebrationOverlay({
    super.key,
    required this.card,
    required this.title,
    required this.onDismiss,
  });

  @override
  State<MatchCelebrationOverlay> createState() =>
      _MatchCelebrationOverlayState();
}

class _MatchCelebrationOverlayState extends State<MatchCelebrationOverlay> {
  bool _visible = true;
  bool _dismissed = false;

  void _dismiss() {
    if (_dismissed) return;

    setState(() {
      _visible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: _visible ? 1 : 0),
        duration: Duration(milliseconds: _visible ? 680 : 360),
        curve: _visible ? Curves.elasticOut : Curves.easeInBack,
        onEnd: () {
          if (_visible || _dismissed) return;

          _dismissed = true;
          widget.onDismiss();
        },
        builder: (context, value, child) {
          final safeValue = value.clamp(0.0, 1.0);
          final exitProgress = _visible ? 0.0 : 1 - safeValue;

          return Material(
            color: const Color(0xFF22304A)
                .withValues(alpha: 0.14 + safeValue * 0.22),
            child: InkWell(
              onTap: _dismiss,
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cardSize = (constraints.biggest.shortestSide * 0.48)
                        .clamp(320.0, 420.0);
                    final introLift = (1 - safeValue) * 90;
                    final exitLift = exitProgress * -150;
                    final angle = _visible
                        ? (1 - safeValue) * math.pi
                        : -exitProgress * math.pi / 5;
                    final bounce = _visible ? math.sin(safeValue * math.pi) : 0;
                    final scale = _visible
                        ? 0.58 + safeValue * 0.48 + bounce * 0.12
                        : 1.06 - exitProgress * 0.42;

                    return Opacity(
                      opacity: safeValue,
                      child: Transform.translate(
                        offset: Offset(0, introLift + exitLift),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle)
                            ..rotateZ(bounce * 0.08)
                            ..scaleByDouble(scale, scale, scale, 1),
                          child: _CelebrationStage(
                            card: widget.card,
                            title: widget.title,
                            cardSize: cardSize,
                            burstProgress: safeValue,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CelebrationStage extends StatelessWidget {
  final CardModel card;
  final String title;
  final double cardSize;
  final double burstProgress;

  const _CelebrationStage({
    required this.card,
    required this.title,
    required this.cardSize,
    required this.burstProgress,
  });

  @override
  Widget build(BuildContext context) {
    final sparkleDistance = 36 + burstProgress * 42;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: const Color(0xFF22304A).withValues(alpha: 0.45),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SizedBox.square(
          dimension: cardSize + 110,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _GlowRing(size: cardSize + 76, opacity: 0.28),
              _GlowRing(size: cardSize + 38, opacity: 0.42),
              _Sparkle(offset: Offset(-sparkleDistance, -sparkleDistance)),
              _Sparkle(
                  offset: Offset(sparkleDistance, -sparkleDistance * 0.85)),
              _Sparkle(offset: Offset(-sparkleDistance * 1.1, sparkleDistance)),
              _Sparkle(offset: Offset(sparkleDistance * 1.05, sparkleDistance)),
              SizedBox.square(
                dimension: cardSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(color: Colors.white, width: 8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB84D).withValues(alpha: 0.55),
                        blurRadius: 42,
                        spreadRadius: 6,
                      ),
                      BoxShadow(
                        color: const Color(0xFF22304A).withValues(alpha: 0.24),
                        blurRadius: 30,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: _CelebrationCardFace(card: card),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlowRing extends StatelessWidget {
  final double size;
  final double opacity;

  const _GlowRing({
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFFD35B).withValues(alpha: opacity),
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  final Offset offset;

  const _Sparkle({required this.offset});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: const Icon(
        Icons.star_rounded,
        color: Color(0xFFFFD35B),
        size: 42,
        shadows: [
          Shadow(
            color: Color(0x6622304A),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }
}

class _CelebrationCardFace extends StatelessWidget {
  final CardModel card;

  const _CelebrationCardFace({required this.card});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: DecoratedBox(
        decoration: BoxDecoration(color: card.color.withValues(alpha: 0.9)),
        child: card.assetPath != null
            ? Image.asset(
                card.assetPath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported_rounded,
                    color: Colors.white,
                    size: 70,
                  );
                },
              )
            : Center(
                child: Text(
                  card.content ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 96,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
      ),
    );
  }
}

class _WinnerPortalDialog extends StatelessWidget {
  final String winnerName;
  final String scoreText;
  final String title;
  final String mainMenuLabel;

  const _WinnerPortalDialog({
    required this.winnerName,
    required this.scoreText,
    required this.title,
    required this.mainMenuLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(32),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          final safeValue = value.clamp(0.0, 1.0);
          final scale = 0.72 + safeValue * 0.28;
          final spin = (1 - safeValue) * math.pi;

          return Opacity(
            opacity: safeValue,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(spin)
                ..scaleByDouble(scale, scale, scale, 1),
              child: child,
            ),
          );
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF1A8),
                Color(0xFFA7E8FF),
                Color(0xFFFFC4D6),
              ],
            ),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: Colors.white, width: 6),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22304A).withValues(alpha: 0.24),
                blurRadius: 34,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: const Color(0xFF22304A),
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 22),
                SizedBox.square(
                  dimension: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const _PortalRing(size: 250, color: Color(0xFFFFD35B)),
                      const _PortalRing(size: 205, color: Color(0xFF6BCEFF)),
                      const _PortalRing(size: 160, color: Color(0xFFFF7A59)),
                      CircleAvatar(
                        radius: 62,
                        backgroundColor: Colors.white,
                        child: Text(
                          winnerName.characters.first.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF22304A),
                            fontSize: 58,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  winnerName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF22304A),
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  scoreText,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFFF7A59),
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 26),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.home_rounded),
                  label: Text(mainMenuLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PortalRing extends StatelessWidget {
  final double size;
  final Color color;

  const _PortalRing({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 900 + size.round()),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * math.pi * 2,
          child: child,
        );
      },
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 5),
            gradient: SweepGradient(
              colors: [
                color.withValues(alpha: 0.25),
                color,
                Colors.white,
                color.withValues(alpha: 0.25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
