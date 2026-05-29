import 'package:flutter/material.dart';

import '../app_settings.dart';
import '../l10n/app_strings.dart';
import '../models/game_state.dart';
import '../services/storage_service.dart';

enum _ScoreMode { single, multi }

enum _ScoreLanguage { global, english, danish }

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StorageService _storageService = StorageService();

  _ScoreMode _mode = _ScoreMode.single;
  _ScoreLanguage _language = _ScoreLanguage.global;
  List<ScoreEntry> _scores = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (_tabController.indexIsChanging) return;
        _loadScores();
      });
    _loadScores();
  }

  Future<void> _loadScores() async {
    final theme = _selectedTheme;
    final languageCode = theme == GameTheme.letters
        ? switch (_language) {
            _ScoreLanguage.english => AppLanguage.english.code,
            _ScoreLanguage.danish => AppLanguage.danish.code,
            _ScoreLanguage.global => null,
          }
        : null;

    final scores = await _storageService.getScores(
      mode: _mode.name,
      theme: theme.assetFolder,
      languageCode: languageCode,
    );

    if (!mounted) return;

    setState(() {
      _scores = scores;
    });
  }

  GameTheme get _selectedTheme =>
      _tabController.index == 0 ? GameTheme.animals : GameTheme.letters;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildList() {
    final strings = AppStrings.of(context);

    if (_scores.isEmpty) {
      return Center(child: Text(strings.noScoresYet));
    }

    return ListView.builder(
      itemCount: _scores.length,
      itemBuilder: (context, index) {
        final entry = _scores[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text('#${index + 1}'),
          ),
          title: Text(entry.playerName),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                Text(_mode == _ScoreMode.single
                    ? _formatTime(entry.timeInSeconds)
                    : strings.points(entry.score)),
                Text('${strings.tries}: ${entry.tries}'),
                Text(
                  '${strings.ratio}: ${entry.successRatio.toStringAsFixed(1)}',
                ),
              ],
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                strings.scorer,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                entry.scorer.round().toString(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters() {
    final strings = AppStrings.of(context);
    final showLanguage = _selectedTheme == GameTheme.letters;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SegmentedButton<_ScoreMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: _ScoreMode.single,
                label: Text(strings.single),
                icon: const Icon(Icons.person),
              ),
              ButtonSegment(
                value: _ScoreMode.multi,
                label: Text(strings.multi),
                icon: const Icon(Icons.people),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) {
              setState(() {
                _mode = selection.first;
              });
              _loadScores();
            },
          ),
          if (showLanguage)
            SegmentedButton<_ScoreLanguage>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: _ScoreLanguage.global,
                  label: Text(strings.global),
                  icon: const Icon(Icons.public),
                ),
                ButtonSegment(
                  value: _ScoreLanguage.english,
                  label: Text(strings.english),
                  icon: const Icon(Icons.language),
                ),
                ButtonSegment(
                  value: _ScoreLanguage.danish,
                  label: Text(strings.danish),
                  icon: const Icon(Icons.language),
                ),
              ],
              selected: {_language},
              onSelectionChanged: (selection) {
                setState(() {
                  _language = selection.first;
                });
                _loadScores();
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.leaderboard),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: strings.animals),
            Tab(text: strings.letters),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }
}
