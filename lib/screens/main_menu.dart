import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';

enum PlayerMode { single, multi }

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();
  PlayerMode _selectedPlayerMode = PlayerMode.single;
  int _selectedGridSize = 6;

  bool get _isMultiplayer => _selectedPlayerMode == PlayerMode.multi;

  void _startGame() {
    if (_isMultiplayer &&
        (_player1Controller.text.trim().isEmpty ||
            _player2Controller.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter names for both players.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          isMultiplayer: _isMultiplayer,
          playerNames: _isMultiplayer
              ? [_player1Controller.text.trim(), _player2Controller.text.trim()]
              : const ['Player 1'],
          theme: GameTheme.animals,
          gridSize: _selectedGridSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    const heroPanel = _HeroPanel();
    final setupPanel = _SetupPanel(
      selectedPlayerMode: _selectedPlayerMode,
      selectedGridSize: _selectedGridSize,
      isMultiplayer: _isMultiplayer,
      player1Controller: _player1Controller,
      player2Controller: _player2Controller,
      onPlayerModeChanged: (mode) {
        setState(() {
          _selectedPlayerMode = mode;
        });
      },
      onGridSizeChanged: (size) {
        setState(() {
          _selectedGridSize = size;
        });
      },
      onStartGame: _startGame,
      onLeaderboard: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
        );
      },
    );

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF1A8),
              Color(0xFFA7E8FF),
              Color(0xFFFFC4D6),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isWide) const Expanded(flex: 5, child: heroPanel),
                    if (!isWide) heroPanel,
                    SizedBox(width: isWide ? 28 : 0, height: isWide ? 0 : 24),
                    if (isWide) Expanded(flex: 4, child: setupPanel),
                    if (!isWide) setupPanel,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _AnimalBadge(label: 'Panda', assetPath: 'assets/animals/1.png'),
            _AnimalBadge(label: 'Tiger', assetPath: 'assets/animals/2.png'),
            _AnimalBadge(label: 'Fox', assetPath: 'assets/animals/3.png'),
          ],
        ),
        const SizedBox(height: 26),
        Text(
          'Kids Memory Game',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: const Color(0xFF22304A),
                fontWeight: FontWeight.w900,
                height: 0.95,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Find the animal pairs, collect matches, and race the timer.',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF31415F),
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 26),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _FeaturePill(icon: Icons.pets, label: 'Animal cards'),
            _FeaturePill(icon: Icons.emoji_events, label: 'Match scores'),
            _FeaturePill(icon: Icons.timer, label: 'Time trial'),
          ],
        ),
      ],
    );
  }
}

class _SetupPanel extends StatelessWidget {
  final PlayerMode selectedPlayerMode;
  final int selectedGridSize;
  final bool isMultiplayer;
  final TextEditingController player1Controller;
  final TextEditingController player2Controller;
  final ValueChanged<PlayerMode> onPlayerModeChanged;
  final ValueChanged<int> onGridSizeChanged;
  final VoidCallback onStartGame;
  final VoidCallback onLeaderboard;

  const _SetupPanel({
    required this.selectedPlayerMode,
    required this.selectedGridSize,
    required this.isMultiplayer,
    required this.player1Controller,
    required this.player2Controller,
    required this.onPlayerModeChanged,
    required this.onGridSizeChanged,
    required this.onStartGame,
    required this.onLeaderboard,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22304A).withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 18),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SectionLabel(
                icon: Icons.sports_esports, label: 'Player Mode'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<PlayerMode>(
                segments: const [
                  ButtonSegment(
                    value: PlayerMode.single,
                    icon: Icon(Icons.person),
                    label: Text('Single'),
                  ),
                  ButtonSegment(
                    value: PlayerMode.multi,
                    icon: Icon(Icons.people),
                    label: Text('Multi'),
                  ),
                ],
                selected: {selectedPlayerMode},
                onSelectionChanged: (newSelection) {
                  onPlayerModeChanged(newSelection.first);
                },
              ),
            ),
            const SizedBox(height: 24),
            const _SectionLabel(icon: Icons.style, label: 'Card Mode'),
            const SizedBox(height: 12),
            const _AnimalModeTile(),
            const SizedBox(height: 24),
            const _SectionLabel(icon: Icons.grid_view, label: 'Board Size'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 4, label: Text('4x4')),
                  ButtonSegment(value: 6, label: Text('6x6')),
                  ButtonSegment(value: 8, label: Text('8x8')),
                  ButtonSegment(value: 10, label: Text('10x10')),
                  ButtonSegment(value: 12, label: Text('12x12')),
                ],
                selected: {selectedGridSize},
                onSelectionChanged: (newSelection) {
                  onGridSizeChanged(newSelection.first);
                },
              ),
            ),
            if (isMultiplayer) ...[
              const SizedBox(height: 24),
              const _SectionLabel(icon: Icons.face, label: 'Players'),
              const SizedBox(height: 14),
              TextField(
                controller: player1Controller,
                decoration: const InputDecoration(
                  labelText: 'Player 1 Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: player2Controller,
                decoration: const InputDecoration(
                  labelText: 'Player 2 Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: FilledButton.icon(
                onPressed: onStartGame,
                icon: Icon(isMultiplayer ? Icons.people : Icons.play_arrow),
                label: Text(
                  isMultiplayer ? 'Start Multiplayer' : 'Start Single Player',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onLeaderboard,
              icon: const Icon(Icons.leaderboard),
              label: const Text('View Leaderboard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimalBadge extends StatelessWidget {
  final String label;
  final String assetPath;

  const _AnimalBadge({
    required this.label,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD35B), width: 4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22304A).withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: SizedBox(
        width: 126,
        height: 146,
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.pets,
                        color: Color(0xFFFF7A59), size: 56);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF22304A),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimalModeTile extends StatelessWidget {
  const _AnimalModeTile();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1A8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD35B), width: 2),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.pets, color: Color(0xFFFF7A59), size: 30),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Animals',
                style: TextStyle(
                  color: Color(0xFF22304A),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Icon(Icons.check_circle, color: Color(0xFF24B47E)),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionLabel({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF3F8CFF)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF22304A),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFFF7A59), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF22304A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
