// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kids Memory Trainer';

  @override
  String get menuSubtitle =>
      'Find the animal pairs, collect matches, and race the timer.';

  @override
  String get animalCards => 'Animal cards';

  @override
  String get matchScores => 'Match scores';

  @override
  String get timeTrial => 'Time trial';

  @override
  String get playerMode => 'Player Mode';

  @override
  String get single => 'Single';

  @override
  String get multi => 'Multi';

  @override
  String get cardMode => 'Card Mode';

  @override
  String get animals => 'Animals';

  @override
  String get letters => 'Letters';

  @override
  String get boardSize => 'Board Size';

  @override
  String get players => 'Players';

  @override
  String get player1Name => 'Player 1 Name';

  @override
  String get player2Name => 'Player 2 Name';

  @override
  String get startSinglePlayer => 'Start Single Player';

  @override
  String get startMultiplayer => 'Start Multiplayer';

  @override
  String get viewLeaderboard => 'View Scorer Board';

  @override
  String get leaderboard => 'Scorer Board';

  @override
  String get global => 'Global';

  @override
  String get english => 'English';

  @override
  String get danish => 'Danish';

  @override
  String get noScoresYet => 'No scores yet. Play a game!';

  @override
  String get singlePlayerFastest => 'Single Player';

  @override
  String get multiplayerTopScores => 'Multiplayer (Top Scores)';

  @override
  String points(int score) {
    return '$score pts';
  }

  @override
  String get scorer => 'Scorer';

  @override
  String get highScore => 'Highscore!';

  @override
  String get highScoreNamePrompt => 'Enter a name for the scorer board.';

  @override
  String get playerName => 'Player name';

  @override
  String get skip => 'Skip';

  @override
  String get enterNames => 'Please enter names for both players.';

  @override
  String get gameSettings => 'Game Settings';

  @override
  String get checkForUpdates => 'Check for Updates';

  @override
  String get createdBy => 'Created by Paris Nakita Kejser';

  @override
  String get updateAvailable => 'New Version Available';

  @override
  String updateAvailableBody(String version) {
    return 'Version $version is ready to download and install.';
  }

  @override
  String get gameUpToDate => 'Ready for more memory fun!';

  @override
  String get gameUpToDateBody =>
      'Kids Memory Trainer is up to date. Happy playing!';

  @override
  String get downloadAndInstall => 'Download and Install';

  @override
  String get later => 'Later';

  @override
  String get downloadingUpdate => 'Downloading update...';

  @override
  String get updateOpened => 'The update was downloaded and started.';

  @override
  String get updateFailed => 'Could not download the update right now.';

  @override
  String get languageLabel => 'Language';

  @override
  String get close => 'Close';

  @override
  String get apply => 'Apply';

  @override
  String get cancel => 'Cancel';

  @override
  String get newGame => 'New Game';

  @override
  String get animalMatchParty => 'Animal Match Party';

  @override
  String get animalTimeTrial => 'Animal Time Trial';

  @override
  String get matches => 'Matches';

  @override
  String get tries => 'Tries';

  @override
  String get ratio => 'Ratio';

  @override
  String get matchFound => 'Match!';

  @override
  String get score => 'Score';

  @override
  String get gameOver => 'Game Over!';

  @override
  String winner(String name) {
    return 'Winner: $name';
  }

  @override
  String get winnerPortalTitle => 'Winner!';

  @override
  String winnerScore(int score) {
    return '$score matches';
  }

  @override
  String completedIn(int seconds) {
    return 'Completed in $seconds seconds!';
  }

  @override
  String seconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get mainMenu => 'Main Menu';

  @override
  String get currentGame => 'Current Game';

  @override
  String get restartApplies => 'Changing board size starts a new game.';

  @override
  String get bee => 'Bee';

  @override
  String get koala => 'Koala';

  @override
  String get fox => 'Fox';
}
