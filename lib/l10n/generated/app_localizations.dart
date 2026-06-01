import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_da.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('da'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kids Memory Trainer'**
  String get appTitle;

  /// No description provided for @menuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find the animal pairs, collect matches, and race the timer.'**
  String get menuSubtitle;

  /// No description provided for @animalCards.
  ///
  /// In en, this message translates to:
  /// **'Animal cards'**
  String get animalCards;

  /// No description provided for @matchScores.
  ///
  /// In en, this message translates to:
  /// **'Match scores'**
  String get matchScores;

  /// No description provided for @timeTrial.
  ///
  /// In en, this message translates to:
  /// **'Time trial'**
  String get timeTrial;

  /// No description provided for @playerMode.
  ///
  /// In en, this message translates to:
  /// **'Player Mode'**
  String get playerMode;

  /// No description provided for @single.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get single;

  /// No description provided for @multi.
  ///
  /// In en, this message translates to:
  /// **'Multi'**
  String get multi;

  /// No description provided for @cardMode.
  ///
  /// In en, this message translates to:
  /// **'Card Mode'**
  String get cardMode;

  /// No description provided for @animals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get animals;

  /// No description provided for @letters.
  ///
  /// In en, this message translates to:
  /// **'Letters'**
  String get letters;

  /// No description provided for @boardSize.
  ///
  /// In en, this message translates to:
  /// **'Board Size'**
  String get boardSize;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @player1Name.
  ///
  /// In en, this message translates to:
  /// **'Player 1 Name'**
  String get player1Name;

  /// No description provided for @player2Name.
  ///
  /// In en, this message translates to:
  /// **'Player 2 Name'**
  String get player2Name;

  /// No description provided for @startSinglePlayer.
  ///
  /// In en, this message translates to:
  /// **'Start Single Player'**
  String get startSinglePlayer;

  /// No description provided for @startMultiplayer.
  ///
  /// In en, this message translates to:
  /// **'Start Multiplayer'**
  String get startMultiplayer;

  /// No description provided for @viewLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'View Scorer Board'**
  String get viewLeaderboard;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Scorer Board'**
  String get leaderboard;

  /// No description provided for @global.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get global;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @danish.
  ///
  /// In en, this message translates to:
  /// **'Danish'**
  String get danish;

  /// No description provided for @noScoresYet.
  ///
  /// In en, this message translates to:
  /// **'No scores yet. Play a game!'**
  String get noScoresYet;

  /// No description provided for @singlePlayerFastest.
  ///
  /// In en, this message translates to:
  /// **'Single Player'**
  String get singlePlayerFastest;

  /// No description provided for @multiplayerTopScores.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer (Top Scores)'**
  String get multiplayerTopScores;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'{score} pts'**
  String points(int score);

  /// No description provided for @scorer.
  ///
  /// In en, this message translates to:
  /// **'Scorer'**
  String get scorer;

  /// No description provided for @highScore.
  ///
  /// In en, this message translates to:
  /// **'Highscore!'**
  String get highScore;

  /// No description provided for @highScoreNamePrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for the scorer board.'**
  String get highScoreNamePrompt;

  /// No description provided for @playerName.
  ///
  /// In en, this message translates to:
  /// **'Player name'**
  String get playerName;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @enterNames.
  ///
  /// In en, this message translates to:
  /// **'Please enter names for both players.'**
  String get enterNames;

  /// No description provided for @gameSettings.
  ///
  /// In en, this message translates to:
  /// **'Game Settings'**
  String get gameSettings;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created by Paris Nakita Kejser'**
  String get createdBy;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'New Version Available'**
  String get updateAvailable;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is ready to download and install.'**
  String updateAvailableBody(String version);

  /// No description provided for @gameUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Ready for more memory fun!'**
  String get gameUpToDate;

  /// No description provided for @gameUpToDateBody.
  ///
  /// In en, this message translates to:
  /// **'Kids Memory Trainer is up to date. Happy playing!'**
  String get gameUpToDateBody;

  /// No description provided for @downloadAndInstall.
  ///
  /// In en, this message translates to:
  /// **'Download and Install'**
  String get downloadAndInstall;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @downloadingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Downloading update...'**
  String get downloadingUpdate;

  /// No description provided for @updateOpened.
  ///
  /// In en, this message translates to:
  /// **'The update was downloaded and started.'**
  String get updateOpened;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not download the update right now.'**
  String get updateFailed;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// No description provided for @animalMatchParty.
  ///
  /// In en, this message translates to:
  /// **'Animal Match Party'**
  String get animalMatchParty;

  /// No description provided for @animalTimeTrial.
  ///
  /// In en, this message translates to:
  /// **'Animal Time Trial'**
  String get animalTimeTrial;

  /// No description provided for @matches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matches;

  /// No description provided for @tries.
  ///
  /// In en, this message translates to:
  /// **'Tries'**
  String get tries;

  /// No description provided for @ratio.
  ///
  /// In en, this message translates to:
  /// **'Ratio'**
  String get ratio;

  /// No description provided for @matchFound.
  ///
  /// In en, this message translates to:
  /// **'Match!'**
  String get matchFound;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over!'**
  String get gameOver;

  /// No description provided for @winner.
  ///
  /// In en, this message translates to:
  /// **'Winner: {name}'**
  String winner(String name);

  /// No description provided for @winnerPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Winner!'**
  String get winnerPortalTitle;

  /// No description provided for @winnerScore.
  ///
  /// In en, this message translates to:
  /// **'{score} matches'**
  String winnerScore(int score);

  /// No description provided for @completedIn.
  ///
  /// In en, this message translates to:
  /// **'Completed in {seconds} seconds!'**
  String completedIn(int seconds);

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String seconds(int seconds);

  /// No description provided for @mainMenu.
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get mainMenu;

  /// No description provided for @currentGame.
  ///
  /// In en, this message translates to:
  /// **'Current Game'**
  String get currentGame;

  /// No description provided for @restartApplies.
  ///
  /// In en, this message translates to:
  /// **'Changing board size starts a new game.'**
  String get restartApplies;

  /// No description provided for @bee.
  ///
  /// In en, this message translates to:
  /// **'Bee'**
  String get bee;

  /// No description provided for @koala.
  ///
  /// In en, this message translates to:
  /// **'Koala'**
  String get koala;

  /// No description provided for @fox.
  ///
  /// In en, this message translates to:
  /// **'Fox'**
  String get fox;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['da', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'da':
      return AppLocalizationsDa();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
