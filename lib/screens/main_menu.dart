import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();
  GameTheme _selectedTheme = GameTheme.animals;
  int _selectedGridSize = 6;

  void _startSinglePlayer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          isMultiplayer: false,
          playerNames: const ['Player 1'],
          theme: _selectedTheme,
          gridSize: _selectedGridSize,
        ),
      ),
    );
  }

  void _startMultiPlayer() {
    if (_player1Controller.text.trim().isEmpty ||
        _player2Controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter names for both players.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          isMultiplayer: true,
          playerNames: [
            _player1Controller.text.trim(),
            _player2Controller.text.trim()
          ],
          theme: _selectedTheme,
          gridSize: _selectedGridSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Project Logo if available
                Image.asset(
                  'images/logo.png',
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.dashboard_customize_rounded,
                    size: 80,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kids Memory Game',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 40),

                // Theme Selector
                const Text('Select Theme',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                SegmentedButton<GameTheme>(
                  segments: const [
                    ButtonSegment(
                        value: GameTheme.animals, label: Text('🐼 Animals')),
                    ButtonSegment(
                        value: GameTheme.numbers, label: Text('🔢 Numbers')),
                    ButtonSegment(
                        value: GameTheme.letters, label: Text('🔠 Letters')),
                    ButtonSegment(
                        value: GameTheme.colors, label: Text('🎨 Colors')),
                  ],
                  selected: {_selectedTheme},
                  onSelectionChanged: (Set<GameTheme> newSelection) {
                    setState(() {
                      _selectedTheme = newSelection.first;
                    });
                  },
                ),

                const SizedBox(height: 32),

                // Grid Size Selector
                const Text('Select Grid Size',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 4, label: Text('4x4')),
                    ButtonSegment(value: 6, label: Text('6x6')),
                    ButtonSegment(value: 8, label: Text('8x8')),
                    ButtonSegment(value: 10, label: Text('10x10')),
                    ButtonSegment(value: 12, label: Text('12x12')),
                  ],
                  selected: {_selectedGridSize},
                  onSelectionChanged: (Set<int> newSelection) {
                    setState(() {
                      _selectedGridSize = newSelection.first;
                    });
                  },
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _startSinglePlayer,
                    icon: const Icon(Icons.timer),
                    label: const Text('Single Player (Time Trial)',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                const Text('Local Multiplayer',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                TextField(
                  controller: _player1Controller,
                  decoration: InputDecoration(
                    labelText: 'Player 1 Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _player2Controller,
                  decoration: InputDecoration(
                    labelText: 'Player 2 Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.tonalIcon(
                    onPressed: _startMultiPlayer,
                    icon: const Icon(Icons.people),
                    label: const Text('Start Multiplayer',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 32),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const LeaderboardScreen()),
                    );
                  },
                  icon: const Icon(Icons.leaderboard),
                  label: const Text('View Leaderboard',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
