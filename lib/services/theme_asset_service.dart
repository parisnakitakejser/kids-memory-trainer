import 'package:flutter/services.dart';

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

  static Future<List<String>> loadAssetsForTheme(GameTheme theme) async {
    final directory = 'assets/${theme.assetFolder}/';
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest
        .listAssets()
        .where((asset) => asset.startsWith(directory))
        .where(_isSupportedImage)
        .toList();

    assets.sort(_naturalSort);
    return assets;
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
