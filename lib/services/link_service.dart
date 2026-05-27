import 'dart:io';

import 'package:flutter/foundation.dart';

class LinkService {
  static Future<void> openGitHubProfile() async {
    const profileUrl = 'https://github.com/parisnakitakejser';

    if (!Platform.isMacOS) return;

    try {
      await Process.run('open', [profileUrl]);
    } catch (error, stackTrace) {
      debugPrint('Unable to open GitHub profile: $error\n$stackTrace');
    }
  }
}
