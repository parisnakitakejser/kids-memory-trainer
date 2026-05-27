import 'package:flutter/material.dart';
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
  bool _gameOverHandled = false;

  @override
  void initState() {
    super.initState();
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
      gridSize: widget.gridSize,
      themeAssets: themeAssets,
    );
    gameState.addListener(_onGameStateChanged);

    setState(() {
      _gameState = gameState;
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
        title: const Text('Game Over!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        content: Text(
          widget.isMultiplayer
              ? '🏆 Winner: ${gameState.players.reduce((a, b) => a.score > b.score ? a : b).name}'
              : '⏱️ Completed in ${gameState.elapsedSeconds} seconds!',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Main Menu', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isMultiplayer ? 'Multiplayer Match' : 'Time Trial'),
        actions: [
          if (!widget.isMultiplayer)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  _formatTime(gameState?.elapsedSeconds ?? 0),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: gameState == null
          ? const Center(child: CircularProgressIndicator())
          : _buildGameBody(context, gameState),
    );
  }

  Widget _buildGameBody(BuildContext context, GameState gameState) {
    return Column(
      children: [
        if (widget.isMultiplayer)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: gameState.players.map((player) {
                bool isCurrent = gameState.currentPlayer == player;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrent
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(player.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isCurrent
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                  : null)),
                      Text('Score: ${player.score}',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.gridSize,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: gameState.cards.length,
                  itemBuilder: (context, index) {
                    return MemoryCard(
                      card: gameState.cards[index],
                      onTap: () => gameState.flipCard(index),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
