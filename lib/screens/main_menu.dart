import 'package:flutter/material.dart';
import '../app_settings.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/game_state.dart';
import '../services/update_service.dart';
import '../widgets/app_footer.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';

enum PlayerMode { single, multi }

class MainMenu extends StatefulWidget {
  final bool enableUpdateCheck;

  const MainMenu({
    super.key,
    this.enableUpdateCheck = true,
  });

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();
  final UpdateService _updateService = UpdateService();
  PlayerMode _selectedPlayerMode = PlayerMode.single;
  GameTheme _selectedTheme = GameTheme.animals;
  int _selectedGridSize = 6;
  bool _checkedForUpdate = false;

  bool get _isMultiplayer => _selectedPlayerMode == PlayerMode.multi;

  @override
  void initState() {
    super.initState();
    if (!widget.enableUpdateCheck) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdateOnStartup();
    });
  }

  Future<void> _checkForUpdateOnStartup() async {
    if (_checkedForUpdate || !mounted) return;
    _checkedForUpdate = true;

    final update = await _updateService.checkForUpdate();
    if (!mounted) return;

    if (update == null) {
      await _showUpToDateDialog();
      return;
    }

    await _showUpdateDialog(update);
  }

  Future<void> _showUpToDateDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final dialogStrings = AppLocalizations.of(context);

        return AlertDialog(
          icon: const Icon(
            Icons.celebration_rounded,
            color: Color(0xFFFF7A59),
            size: 42,
          ),
          title: Text(dialogStrings.gameUpToDate),
          content: Text(dialogStrings.gameUpToDateBody),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(dialogStrings.close),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUpdateDialog(UpdateInfo update) async {
    final strings = AppLocalizations.of(context);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var isDownloading = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final dialogStrings = AppLocalizations.of(context);

            return AlertDialog(
              title: Text(dialogStrings.updateAvailable),
              content: Text(dialogStrings.updateAvailableBody(update.version)),
              actions: [
                TextButton(
                  onPressed: isDownloading
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(dialogStrings.later),
                ),
                FilledButton.icon(
                  onPressed: isDownloading
                      ? null
                      : () async {
                          setDialogState(() {
                            isDownloading = true;
                          });

                          final messenger = ScaffoldMessenger.of(context);
                          messenger.showSnackBar(
                            SnackBar(content: Text(strings.downloadingUpdate)),
                          );

                          try {
                            final file =
                                await _updateService.downloadUpdate(update);
                            await _updateService.installUpdate(file);

                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }

                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(content: Text(strings.updateOpened)),
                              );
                            }
                          } catch (_) {
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(content: Text(strings.updateFailed)),
                              );
                            }
                            setDialogState(() {
                              isDownloading = false;
                            });
                          }
                        },
                  icon: isDownloading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_rounded),
                  label: Text(dialogStrings.downloadAndInstall),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showSettings() async {
    final settings = AppSettingsScope.of(context);
    var selectedLanguage = settings.language;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final dialogStrings = AppLocalizations.of(context);

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
                          child: Text(switch (language) {
                            AppLanguage.english => dialogStrings.english,
                            AppLanguage.danish => dialogStrings.danish,
                          }),
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
    final strings = AppLocalizations.of(context);

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
          theme: _selectedTheme,
          gridSize: _selectedGridSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final heroPanel = _HeroPanel(strings: strings);
    final setupPanel = _SetupPanel(
      strings: strings,
      selectedPlayerMode: _selectedPlayerMode,
      selectedTheme: _selectedTheme,
      selectedGridSize: _selectedGridSize,
      isMultiplayer: _isMultiplayer,
      player1Controller: _player1Controller,
      player2Controller: _player2Controller,
      onPlayerModeChanged: (mode) {
        setState(() {
          _selectedPlayerMode = mode;
        });
      },
      onThemeChanged: (theme) {
        setState(() {
          _selectedTheme = theme;
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
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
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
                          SizedBox(
                              width: isWide ? 28 : 0, height: isWide ? 0 : 24),
                          if (isWide) Expanded(flex: 4, child: setupPanel),
                          if (!isWide) setupPanel,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 16,
            bottom: 14,
            child: AppFooter(),
          ),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final AppLocalizations strings;

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
                label: strings.bee, assetPath: 'build_assets/animals/1.jpg'),
            _AnimalBadge(
                label: strings.fox, assetPath: 'build_assets/animals/2.jpg'),
            _AnimalBadge(
                label: strings.koala, assetPath: 'build_assets/animals/3.jpg'),
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
  final AppLocalizations strings;
  final PlayerMode selectedPlayerMode;
  final GameTheme selectedTheme;
  final int selectedGridSize;
  final bool isMultiplayer;
  final TextEditingController player1Controller;
  final TextEditingController player2Controller;
  final ValueChanged<PlayerMode> onPlayerModeChanged;
  final ValueChanged<GameTheme> onThemeChanged;
  final ValueChanged<int> onGridSizeChanged;
  final VoidCallback onStartGame;
  final VoidCallback onSettings;
  final VoidCallback onLeaderboard;

  const _SetupPanel({
    required this.strings,
    required this.selectedPlayerMode,
    required this.selectedTheme,
    required this.selectedGridSize,
    required this.isMultiplayer,
    required this.player1Controller,
    required this.player2Controller,
    required this.onPlayerModeChanged,
    required this.onThemeChanged,
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
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<GameTheme>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: GameTheme.animals,
                    icon: const Icon(Icons.pets),
                    label: Text(strings.animals),
                  ),
                  ButtonSegment(
                    value: GameTheme.letters,
                    icon: const Icon(Icons.abc),
                    label: Text(strings.letters),
                  ),
                ],
                selected: {selectedTheme},
                onSelectionChanged: (newSelection) {
                  onThemeChanged(newSelection.first);
                },
              ),
            ),
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
