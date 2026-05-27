import 'package:flutter/material.dart';
import '../app_settings.dart';
import '../l10n/app_strings.dart';
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

  Future<void> _showSettings() async {
    final settings = AppSettingsScope.of(context);
    var selectedLanguage = settings.language;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final dialogStrings = AppStrings.of(context);

            return AlertDialog(
              title: Text(dialogStrings.gameSettings),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dialogStrings.languageLabel,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<AppLanguage>(
                      initialValue: selectedLanguage,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.language),
                        labelText: dialogStrings.languageLabel,
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(dialogStrings.cancel),
                ),
                FilledButton(
                  onPressed: () async {
                    await settings.setLanguage(selectedLanguage);
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: Text(dialogStrings.apply),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _startGame() {
    final strings = AppStrings.of(context);

    if (_isMultiplayer &&
        (_player1Controller.text.trim().isEmpty ||
            _player2Controller.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.enterNames)),
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
    final strings = AppStrings.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final heroPanel = _HeroPanel(strings: strings);
    final setupPanel = _SetupPanel(
      strings: strings,
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
      onSettings: _showSettings,
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
                    if (isWide) Expanded(flex: 5, child: heroPanel),
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
  final AppStrings strings;

  const _HeroPanel({required this.strings});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _AnimalBadge(
                label: strings.panda, assetPath: 'assets/animals/1.png'),
            _AnimalBadge(
                label: strings.tiger, assetPath: 'assets/animals/2.png'),
            _AnimalBadge(label: strings.fox, assetPath: 'assets/animals/3.png'),
          ],
        ),
        const SizedBox(height: 26),
        Text(
          strings.appTitle,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: const Color(0xFF22304A),
                fontWeight: FontWeight.w900,
                height: 0.95,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          strings.menuSubtitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF31415F),
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _FeaturePill(icon: Icons.pets, label: strings.animalCards),
            _FeaturePill(icon: Icons.emoji_events, label: strings.matchScores),
            _FeaturePill(icon: Icons.timer, label: strings.timeTrial),
          ],
        ),
      ],
    );
  }
}

class _SetupPanel extends StatelessWidget {
  final AppStrings strings;
  final PlayerMode selectedPlayerMode;
  final int selectedGridSize;
  final bool isMultiplayer;
  final TextEditingController player1Controller;
  final TextEditingController player2Controller;
  final ValueChanged<PlayerMode> onPlayerModeChanged;
  final ValueChanged<int> onGridSizeChanged;
  final VoidCallback onStartGame;
  final VoidCallback onSettings;
  final VoidCallback onLeaderboard;

  const _SetupPanel({
    required this.strings,
    required this.selectedPlayerMode,
    required this.selectedGridSize,
    required this.isMultiplayer,
    required this.player1Controller,
    required this.player2Controller,
    required this.onPlayerModeChanged,
    required this.onGridSizeChanged,
    required this.onStartGame,
    required this.onSettings,
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
            _SectionLabel(
                icon: Icons.sports_esports, label: strings.playerMode),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<PlayerMode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: PlayerMode.single,
                    icon: const Icon(Icons.person),
                    label: Text(strings.single),
                  ),
                  ButtonSegment(
                    value: PlayerMode.multi,
                    icon: const Icon(Icons.people),
                    label: Text(strings.multi),
                  ),
                ],
                selected: {selectedPlayerMode},
                onSelectionChanged: (newSelection) {
                  onPlayerModeChanged(newSelection.first);
                },
              ),
            ),
            const SizedBox(height: 24),
            _SectionLabel(icon: Icons.style, label: strings.cardMode),
            const SizedBox(height: 12),
            _AnimalModeTile(label: strings.animals),
            const SizedBox(height: 24),
            _SectionLabel(icon: Icons.grid_view, label: strings.boardSize),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
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
                  onGridSizeChanged(newSelection.first);
                },
              ),
            ),
            if (isMultiplayer) ...[
              const SizedBox(height: 24),
              _SectionLabel(icon: Icons.face, label: strings.players),
              const SizedBox(height: 14),
              TextField(
                controller: player1Controller,
                decoration: InputDecoration(
                  labelText: strings.player1Name,
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: player2Controller,
                decoration: InputDecoration(
                  labelText: strings.player2Name,
                  prefixIcon: const Icon(Icons.person_outline),
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
                  isMultiplayer
                      ? strings.startMultiplayer
                      : strings.startSinglePlayer,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onSettings,
                icon: const Icon(Icons.settings),
                label: Text(
                  strings.gameSettings,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onLeaderboard,
              icon: const Icon(Icons.leaderboard),
              label: Text(strings.viewLeaderboard,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
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
  final String label;

  const _AnimalModeTile({required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1A8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD35B), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.pets, color: Color(0xFFFF7A59), size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF22304A),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Icon(Icons.check_circle, color: Color(0xFF24B47E)),
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
