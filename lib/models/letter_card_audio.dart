enum LetterCase { upper, lower }

class LetterCardAudio {
  final String languageCode;
  final String letterSlug;
  final String displayLetter;
  final LetterCase letterCase;

  const LetterCardAudio({
    required this.languageCode,
    required this.letterSlug,
    required this.displayLetter,
    required this.letterCase,
  });

  String get caseSlug => switch (letterCase) {
        LetterCase.upper => 'upper',
        LetterCase.lower => 'lower',
      };

  String get letterSoundPath =>
      'assets/sounds/letters/$languageCode/$letterSlug-$caseSlug-letter.aiff';

  String get animalSoundPath =>
      'assets/sounds/letters/$languageCode/$letterSlug-$caseSlug-animal.aiff';

  static LetterCardAudio? fromAssetPath(String assetPath) {
    final match = RegExp(
      r'^(?:build_assets|assets)/letters/(en|da)/(.+)-(upper|lower|loer)\.[^.]+$',
    ).firstMatch(assetPath);
    if (match == null) return null;

    final languageCode = match.group(1)!;
    final letterSlug = match.group(2)!;
    final caseSlug = match.group(3)! == 'upper' ? 'upper' : 'lower';
    final displayLetter = _displayLetterForSlug(languageCode, letterSlug);
    if (displayLetter == null) return null;

    return LetterCardAudio(
      languageCode: languageCode,
      letterSlug: letterSlug,
      displayLetter: caseSlug == 'upper'
          ? displayLetter.toUpperCase()
          : displayLetter.toLowerCase(),
      letterCase: caseSlug == 'upper' ? LetterCase.upper : LetterCase.lower,
    );
  }

  static LetterCardAudio? fromContent(
    String content, {
    required String languageCode,
  }) {
    final slug = _slugForDisplayLetter(languageCode, content);
    if (slug == null) return null;

    final isUpper = content == content.toUpperCase();
    final isLower = content == content.toLowerCase();
    if (!isUpper && !isLower) return null;

    return LetterCardAudio(
      languageCode: languageCode,
      letterSlug: slug,
      displayLetter: content,
      letterCase: isUpper ? LetterCase.upper : LetterCase.lower,
    );
  }

  static String? _displayLetterForSlug(String languageCode, String slug) {
    if (languageCode == 'da') {
      return switch (slug) {
        'ae' => 'æ',
        'oe' => 'ø',
        'aa' => 'å',
        _ => _singleLatinLetter(slug),
      };
    }

    return _singleLatinLetter(slug);
  }

  static String? _slugForDisplayLetter(String languageCode, String content) {
    final normalized = content.toLowerCase();
    if (languageCode == 'da') {
      return switch (normalized) {
        'æ' => 'ae',
        'ø' => 'oe',
        'å' => 'aa',
        _ => _singleLatinLetter(normalized),
      };
    }

    return _singleLatinLetter(normalized);
  }

  static String? _singleLatinLetter(String value) {
    if (RegExp(r'^[a-z]$').hasMatch(value)) return value;
    return null;
  }
}
