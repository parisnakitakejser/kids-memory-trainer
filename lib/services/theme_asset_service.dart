import 'package:flutter/services.dart';

import '../app_settings.dart';
import '../models/game_state.dart';

class ThemeAssetService {
  static const Set<String> _imageExtensions = {
    '.avif',
    '.gif',
    '.jpeg',
    '.jpg',
    '.png',
    '.webp',
  };

  static Future<List<String>> loadAssetsForTheme(
    GameTheme theme, {
    AppLanguage language = AppLanguage.english,
  }) async {
    final directory = _directoryForTheme(theme, language);
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest
        .listAssets()
        .where((asset) => asset.startsWith(directory))
        .where(_isSupportedImage)
        .toList();

    assets.sort(_naturalSort);
    return assets;
  }

  static String _directoryForTheme(GameTheme theme, AppLanguage language) {
    if (theme == GameTheme.animals) {
      return 'build_assets/animals/';
    }

    if (theme == GameTheme.letters) {
      return 'build_assets/letters/${language.code}/';
    }

    return 'build_assets/${theme.assetFolder}/';
  }

  static bool _isSupportedImage(String asset) {
    final lowerAsset = asset.toLowerCase();
    return _imageExtensions.any(lowerAsset.endsWith);
  }

  static int _naturalSort(String a, String b) {
    final aName = a.split('/').last;
    final bName = b.split('/').last;
    final aNumber = int.tryParse(aName.split('.').first);
    final bNumber = int.tryParse(bName.split('.').first);

    if (aNumber != null && bNumber != null) {
      return aNumber.compareTo(bNumber);
    }

    return aName.compareTo(bName);
  }
}
