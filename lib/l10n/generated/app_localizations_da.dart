// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appTitle => 'Kids Memory Trainer';

  @override
  String get menuSubtitle => 'Find dyrepar, saml stik, og slå tiden.';

  @override
  String get animalCards => 'Dyrekort';

  @override
  String get matchScores => 'Stik og point';

  @override
  String get timeTrial => 'Tidsspil';

  @override
  String get playerMode => 'Spiltype';

  @override
  String get single => 'Alene';

  @override
  String get multi => 'Flere';

  @override
  String get cardMode => 'Korttype';

  @override
  String get animals => 'Dyr';

  @override
  String get letters => 'Bogstaver';

  @override
  String get boardSize => 'Brætstørrelse';

  @override
  String get players => 'Spillere';

  @override
  String get player1Name => 'Spiller 1 navn';

  @override
  String get player2Name => 'Spiller 2 navn';

  @override
  String get startSinglePlayer => 'Start alene';

  @override
  String get startMultiplayer => 'Start med flere';

  @override
  String get viewLeaderboard => 'Se scorerliste';

  @override
  String get leaderboard => 'Scorerliste';

  @override
  String get global => 'Global';

  @override
  String get english => 'Engelsk';

  @override
  String get danish => 'Dansk';

  @override
  String get noScoresYet => 'Ingen rekorder endnu. Spil et spil!';

  @override
  String get singlePlayerFastest => 'Alene';

  @override
  String get multiplayerTopScores => 'Flere spillere (flest point)';

  @override
  String points(int score) {
    return '$score point';
  }

  @override
  String get scorer => 'Scorer';

  @override
  String get highScore => 'Rekord!';

  @override
  String get highScoreNamePrompt => 'Skriv et navn til scorerlisten.';

  @override
  String get playerName => 'Spillernavn';

  @override
  String get skip => 'Spring over';

  @override
  String get enterNames => 'Skriv navne på begge spillere.';

  @override
  String get gameSettings => 'Spilindstillinger';

  @override
  String get createdBy => 'Lavet af Paris Nakita Kejser';

  @override
  String get updateAvailable => 'Ny version tilgængelig';

  @override
  String updateAvailableBody(String version) {
    return 'Version $version er klar til download og installation.';
  }

  @override
  String get gameUpToDate => 'Klar til mere hukommelsessjov!';

  @override
  String get gameUpToDateBody =>
      'Kids Memory Trainer er opdateret. God fornøjelse!';

  @override
  String get downloadAndInstall => 'Download og installer';

  @override
  String get later => 'Senere';

  @override
  String get downloadingUpdate => 'Downloader opdatering...';

  @override
  String get updateOpened => 'Opdateringen blev downloadet og startet.';

  @override
  String get updateFailed => 'Kunne ikke downloade opdateringen lige nu.';

  @override
  String get languageLabel => 'Sprog';

  @override
  String get close => 'Luk';

  @override
  String get apply => 'Brug';

  @override
  String get cancel => 'Annuller';

  @override
  String get newGame => 'Nyt spil';

  @override
  String get animalMatchParty => 'Dyre-match fest';

  @override
  String get animalTimeTrial => 'Dyretidsspil';

  @override
  String get matches => 'Stik';

  @override
  String get tries => 'Forsøg';

  @override
  String get ratio => 'Ratio';

  @override
  String get matchFound => 'Stik!';

  @override
  String get score => 'Point';

  @override
  String get gameOver => 'Spillet er slut!';

  @override
  String winner(String name) {
    return 'Vinder: $name';
  }

  @override
  String get winnerPortalTitle => 'Vinder!';

  @override
  String winnerScore(int score) {
    return '$score stik';
  }

  @override
  String completedIn(int seconds) {
    return 'Klar på $seconds sekunder!';
  }

  @override
  String seconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get mainMenu => 'Hovedmenu';

  @override
  String get currentGame => 'Nuværende spil';

  @override
  String get restartApplies =>
      'Når brætstørrelsen ændres, starter et nyt spil.';

  @override
  String get bee => 'Bi';

  @override
  String get koala => 'Koala';

  @override
  String get fox => 'Ræv';
}
