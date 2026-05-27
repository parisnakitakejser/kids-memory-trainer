import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../services/storage_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StorageService _storageService = StorageService();

  List<ScoreEntry> _singlePlayerScores = [];
  List<ScoreEntry> _multiPlayerScores = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadScores();
  }

  Future<void> _loadScores() async {
    final single = await _storageService.getScores('single');
    final multi = await _storageService.getScores('multi');
    setState(() {
      _singlePlayerScores = single;
      _multiPlayerScores = multi;
    });
  }

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

  Widget _buildList(List<ScoreEntry> scores, bool isTimeBased) {
    final strings = AppStrings.of(context);

    if (scores.isEmpty) {
      return Center(child: Text(strings.noScoresYet));
    }

    return ListView.builder(
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final entry = scores[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text('#${index + 1}'),
          ),
          title: Text(entry.playerName),
          trailing: Text(
            isTimeBased
                ? _formatTime(entry.timeInSeconds)
                : strings.points(entry.score),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        );
      },
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
            Tab(text: strings.singlePlayerFastest),
            Tab(text: strings.multiplayerTopScores),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_singlePlayerScores, true),
          _buildList(_multiPlayerScores, false),
        ],
      ),
    );
  }
}
