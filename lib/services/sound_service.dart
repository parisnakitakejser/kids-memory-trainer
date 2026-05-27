import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SoundService {
  static const String _matchAssetPath = 'assets/sounds/match_chime.wav';
  static const String _winnerAssetPath = 'assets/sounds/winner_applause.wav';
  static File? _matchSoundFile;
  static File? _winnerSoundFile;

  static Future<void> playMatch() async {
    await _playAsset(
      assetPath: _matchAssetPath,
      tempFileName: 'kids_memory_match_chime.wav',
      cachedFile: () => _matchSoundFile,
      setCachedFile: (file) => _matchSoundFile = file,
      fallback: SystemSoundType.click,
    );
  }

  static Future<void> playWinnerApplause() async {
    await _playAsset(
      assetPath: _winnerAssetPath,
      tempFileName: 'kids_memory_winner_applause.wav',
      cachedFile: () => _winnerSoundFile,
      setCachedFile: (file) => _winnerSoundFile = file,
      fallback: SystemSoundType.alert,
    );
  }

  static Future<void> _playAsset({
    required String assetPath,
    required String tempFileName,
    required File? Function() cachedFile,
    required void Function(File file) setCachedFile,
    required SystemSoundType fallback,
  }) async {
    if (!Platform.isMacOS) {
      await SystemSound.play(fallback);
      return;
    }

    try {
      final soundFile = await _prepareSound(
        assetPath: assetPath,
        tempFileName: tempFileName,
        cachedFile: cachedFile,
        setCachedFile: setCachedFile,
      );
      await Process.start('afplay', [soundFile.path]);
    } catch (error, stackTrace) {
      debugPrint('Unable to play sound: $error\n$stackTrace');
      await SystemSound.play(fallback);
    }
  }

  static Future<File> _prepareSound({
    required String assetPath,
    required String tempFileName,
    required File? Function() cachedFile,
    required void Function(File file) setCachedFile,
  }) async {
    final existingFile = cachedFile();
    if (existingFile != null && await existingFile.exists()) {
      return existingFile;
    }

    final data = await rootBundle.load(assetPath);
    final file = File('${Directory.systemTemp.path}/$tempFileName');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    setCachedFile(file);
    return file;
  }
}
