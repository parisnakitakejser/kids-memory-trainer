import 'package:flutter/material.dart';
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
    if (scores.isEmpty) {
      return const Center(child: Text('No scores yet. Play a game!'));
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
                : '${entry.score} pts',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Single Player (Fastest)'),
            Tab(text: 'Multiplayer (Top Scores)'),
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
