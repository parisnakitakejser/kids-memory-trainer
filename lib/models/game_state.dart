import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum GameTheme { colors, animals, numbers, letters }

extension GameThemeAssets on GameTheme {
  String get assetFolder {
    switch (this) {
      case GameTheme.animals:
        return 'animals';
      case GameTheme.numbers:
        return 'numbers';
      case GameTheme.letters:
        return 'letters';
      case GameTheme.colors:
        return 'colors';
    }
  }
}

class CardModel {
  final String id;
  final Color color;
  final String? content;
  final String? assetPath;
  bool isFaceUp;
  bool isMatched;

  CardModel({
    required this.id,
    required this.color,
    this.content,
    this.assetPath,
    this.isFaceUp = false,
    this.isMatched = false,
  });

  String get matchKey => assetPath ?? content ?? color.toARGB32().toString();
}

class Player {
  final String name;
  int score;
  final List<CardModel> matchedCards;

  Player({required this.name, this.score = 0}) : matchedCards = [];
}

class GameState extends ChangeNotifier {
  final bool isMultiplayer;
  final List<Player> players;
  final GameTheme theme;
  final int gridSize;
  final List<String> themeAssets;

  List<CardModel> cards = [];
  int currentPlayerIndex = 0;

  // Single player timer
  int elapsedSeconds = 0;
  Timer? _timer;

  // Interaction state
  CardModel? firstCard;
  CardModel? secondCard;
  bool isProcessing = false;
  bool isGameOver = false;

  GameState({
    required this.isMultiplayer,
    required List<String> playerNames,
    required this.theme,
    required this.gridSize,
    this.themeAssets = const [],
  }) : players = playerNames.map((name) => Player(name: name)).toList() {
    _initializeBoard();
    if (!isMultiplayer) {
      _startTimer();
    }
  }

  Player get currentPlayer => players[currentPlayerIndex];

  int get matchedPairs => cards.where((c) => c.isMatched).length ~/ 2;

  List<CardModel> get matchedPairPreviews {
    final seen = <String>{};
    final previews = <CardModel>[];

    for (final card in cards) {
      if (card.isMatched && seen.add(card.matchKey)) {
        previews.add(card);
      }
    }

    return previews;
  }

  static const List<String> _animalEmojis = [
    '🐶',
    '🐱',
    '🐭',
    '🐹',
    '🐰',
    '🦊',
    '🐻',
    '🐼',
    '🐨',
    '🐯',
    '🦁',
    '🐮',
    '🐷',
    '🐸',
    '🐵',
    '🐔',
    '🐧',
    '🐦',
    '🐤',
    '🦆',
    '🦅',
    '🦉',
    '🦇',
    '🐺',
    '🐗',
    '🐴',
    '🦄',
    '🐝',
    '🐛',
    '🦋',
    '🐌',
    '🐞',
    '🐜',
    '🦟',
    '🦗',
    '🕷',
    '🐢',
    '🐍',
    '🦎',
    '🦖',
    '🦕',
    '🐙',
    '🦑',
    '🦐',
    '🦞',
    '🦀',
    '🐡',
    '🐠',
    '🐟',
    '🐬',
    '🐳',
    '🐋',
    '🦈',
    '🐊',
    '🐅',
    '🐆',
    '🦓',
    '🦍',
    '🦧',
    '🐘',
    '🦛',
    '🦏',
    '🐪',
    '🦒',
    '🦘',
    '🐃',
    '🐂',
    '🐄',
    '🐎',
    '🐖',
    '🐏',
    '🐑'
  ];

  static const List<String> _letters = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z',
    'Α',
    'Β',
    'Γ',
    'Δ',
    'Ε',
    'Ζ',
    'Η',
    'Θ',
    'Ι',
    'Κ',
    'Λ',
    'Μ',
    'Ν',
    'Ξ',
    'Ο',
    'Π',
    'Ρ',
    'Σ',
    'Τ',
    'Υ'
  ];

  void _initializeBoard() {
    final int totalPairs = (gridSize * gridSize) ~/ 2;
    final List<Color> palette = _generatePalette(totalPairs);

    const uuid = Uuid();
    for (int i = 0; i < totalPairs; i++) {
      final color = palette[i];
      String? content;
      String? assetPath;

      switch (theme) {
        case GameTheme.animals:
          if (i < themeAssets.length) {
            assetPath = themeAssets[i];
          } else {
            content = _animalEmojis[i];
          }
          break;
        case GameTheme.numbers:
          if (i < themeAssets.length) {
            assetPath = themeAssets[i];
          } else {
            content = '${i + 1}';
          }
          break;
        case GameTheme.letters:
          if (i < themeAssets.length) {
            assetPath = themeAssets[i];
          } else {
            content = _letters[i];
          }
          break;
        case GameTheme.colors:
          if (i < themeAssets.length) {
            assetPath = themeAssets[i];
          } else {
            content = null;
          }
          break;
      }

      cards.add(CardModel(
          id: uuid.v4(), color: color, content: content, assetPath: assetPath));
      cards.add(CardModel(
          id: uuid.v4(), color: color, content: content, assetPath: assetPath));
    }
    cards.shuffle();
    notifyListeners();
  }

  List<Color> _generatePalette(int count) {
    List<Color> colors = [];
    for (int i = 0; i < count; i++) {
      double hue = (i * 360 / count) % 360;
      double saturation = i % 2 == 0 ? 0.8 : 1.0;
      double lightness = i % 3 == 0 ? 0.6 : (i % 3 == 1 ? 0.5 : 0.7);
      colors.add(HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor());
    }
    return colors;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSeconds++;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void flipCard(int index) async {
    if (isProcessing || isGameOver) return;

    final card = cards[index];
    if (card.isFaceUp || card.isMatched) return;

    card.isFaceUp = true;
    notifyListeners();

    if (firstCard == null) {
      firstCard = card;
    } else if (secondCard == null) {
      secondCard = card;
      _checkMatch();
    }
  }

  void _checkMatch() async {
    isProcessing = true;
    notifyListeners();

    final bool isMatch = firstCard!.matchKey == secondCard!.matchKey;

    if (isMatch) {
      firstCard!.isMatched = true;
      secondCard!.isMatched = true;

      if (isMultiplayer) {
        currentPlayer.score++;
        currentPlayer.matchedCards.add(firstCard!);
      }

      _checkGameOver();
    } else {
      await Future.delayed(const Duration(milliseconds: 1000));
      firstCard!.isFaceUp = false;
      secondCard!.isFaceUp = false;

      if (isMultiplayer) {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
      }
    }

    firstCard = null;
    secondCard = null;
    isProcessing = false;
    notifyListeners();
  }

  void _checkGameOver() {
    if (cards.every((card) => card.isMatched)) {
      isGameOver = true;
      _timer?.cancel();
    }
  }
}
