import 'package:flutter/widgets.dart';

import '../app_settings.dart';

class AppStrings {
  final AppLanguage currentLanguage;

  const AppStrings(this.currentLanguage);

  static AppStrings of(BuildContext context) {
    return AppStrings(AppSettingsScope.of(context).language);
  }

  String _pick({
    required String en,
    required String da,
  }) {
    switch (currentLanguage) {
      case AppLanguage.english:
        return en;
      case AppLanguage.danish:
        return da;
    }
  }

  String get appTitle => _pick(
        en: 'Kids Memory Game',
        da: 'Huskespil for børn',
      );

  String get menuSubtitle => _pick(
        en: 'Find the animal pairs, collect matches, and race the timer.',
        da: 'Find dyrepar, saml stik, og slå tiden.',
      );

  String get animalCards => _pick(
        en: 'Animal cards',
        da: 'Dyrekort',
      );

  String get matchScores => _pick(
        en: 'Match scores',
        da: 'Stik og point',
      );

  String get timeTrial => _pick(
        en: 'Time trial',
        da: 'Tidsspil',
      );

  String get playerMode => _pick(
        en: 'Player Mode',
        da: 'Spiltype',
      );

  String get single => _pick(en: 'Single', da: 'Alene');

  String get multi => _pick(en: 'Multi', da: 'Flere');

  String get cardMode => _pick(
        en: 'Card Mode',
        da: 'Korttype',
      );

  String get animals => _pick(en: 'Animals', da: 'Dyr');

  String get boardSize => _pick(
        en: 'Board Size',
        da: 'Brætstørrelse',
      );

  String get players => _pick(en: 'Players', da: 'Spillere');

  String get player1Name => _pick(
        en: 'Player 1 Name',
        da: 'Spiller 1 navn',
      );

  String get player2Name => _pick(
        en: 'Player 2 Name',
        da: 'Spiller 2 navn',
      );

  String get startSinglePlayer => _pick(
        en: 'Start Single Player',
        da: 'Start alene',
      );

  String get startMultiplayer => _pick(
        en: 'Start Multiplayer',
        da: 'Start med flere',
      );

  String get viewLeaderboard => _pick(
        en: 'View Leaderboard',
        da: 'Se rekordliste',
      );

  String get leaderboard => _pick(en: 'Leaderboard', da: 'Rekordliste');

  String get noScoresYet => _pick(
        en: 'No scores yet. Play a game!',
        da: 'Ingen rekorder endnu. Spil et spil!',
      );

  String get singlePlayerFastest => _pick(
        en: 'Single Player (Fastest)',
        da: 'Alene (hurtigst)',
      );

  String get multiplayerTopScores => _pick(
        en: 'Multiplayer (Top Scores)',
        da: 'Flere spillere (flest point)',
      );

  String points(int score) => _pick(en: '$score pts', da: '$score point');

  String get enterNames => _pick(
        en: 'Please enter names for both players.',
        da: 'Skriv navne på begge spillere.',
      );

  String get gameSettings => _pick(
        en: 'Game Settings',
        da: 'Spilindstillinger',
      );

  String get languageLabel => _pick(en: 'Language', da: 'Sprog');

  String get close => _pick(en: 'Close', da: 'Luk');

  String get apply => _pick(en: 'Apply', da: 'Brug');

  String get cancel => _pick(en: 'Cancel', da: 'Annuller');

  String get newGame => _pick(en: 'New Game', da: 'Nyt spil');

  String get animalMatchParty => _pick(
        en: 'Animal Match Party',
        da: 'Dyre-match fest',
      );

  String get animalTimeTrial => _pick(
        en: 'Animal Time Trial',
        da: 'Dyretidsspil',
      );

  String get matches => _pick(en: 'Matches', da: 'Stik');

  String get matchFound => _pick(en: 'Match!', da: 'Stik!');

  String get score => _pick(en: 'Score', da: 'Point');

  String get gameOver => _pick(en: 'Game Over!', da: 'Spillet er slut!');

  String winner(String name) => _pick(
        en: 'Winner: $name',
        da: 'Vinder: $name',
      );

  String completedIn(int seconds) => _pick(
        en: 'Completed in $seconds seconds!',
        da: 'Klar på $seconds sekunder!',
      );

  String get mainMenu => _pick(en: 'Main Menu', da: 'Hovedmenu');

  String get currentGame => _pick(
        en: 'Current Game',
        da: 'Nuværende spil',
      );

  String get restartApplies => _pick(
        en: 'Changing board size starts a new game.',
        da: 'Når brætstørrelsen ændres, starter et nyt spil.',
      );

  String get panda => _pick(en: 'Panda', da: 'Panda');

  String get tiger => _pick(en: 'Tiger', da: 'Tiger');

  String get fox => _pick(en: 'Fox', da: 'Ræv');
}
