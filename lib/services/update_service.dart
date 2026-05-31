import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class UpdateInfo {
  final String version;
  final Uri downloadUrl;
  final String fileName;

  const UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.fileName,
  });
}

class UpdateService {
  static const String currentVersion =
      String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');
  static final Uri _releasesUrl = Uri.https(
    'api.github.com',
    '/repos/parisnakitakejser/kids-memory-trainer/releases',
    {'per_page': '20'},
  );

  Future<UpdateInfo?> checkForUpdate() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(_releasesUrl);
      request.headers
          .set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      request.headers.set(HttpHeaders.userAgentHeader, 'kids-memory-trainer');

      final response = await request.close();
      if (response.statusCode == HttpStatus.notFound) return null;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const HttpException('GitHub release check failed');
      }

      final body = await utf8.decodeStream(response);
      final json = jsonDecode(body) as List<dynamic>;
      final releases = json
          .whereType<Map<String, dynamic>>()
          .where((release) => release['draft'] != true)
          .map(_updateInfoFromRelease)
          .whereType<UpdateInfo>()
          .where((update) => isNewerVersion(update.version, currentVersion))
          .toList()
        ..sort((a, b) => _compareVersions(b.version, a.version));

      return releases.firstOrNull;
    } catch (error, stackTrace) {
      debugPrint('Unable to check for updates: $error\n$stackTrace');
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<File> downloadUpdate(UpdateInfo update) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(update.downloadUrl);
      request.headers.set(HttpHeaders.userAgentHeader, 'kids-memory-trainer');

      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const HttpException('Update download failed');
      }

      final file = File('${Directory.systemTemp.path}/${update.fileName}');
      final sink = file.openWrite();
      await response.pipe(sink);
      await sink.close();
      return file;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> openInstaller(File file) async {
    if (!Platform.isMacOS) return;
    await Process.run('open', [file.path]);
  }

  static String _normalizeVersion(String version) {
    return version.trim().replaceFirst(RegExp(r'^[vV]'), '').split('+').first;
  }

  static UpdateInfo? _updateInfoFromRelease(Map<String, dynamic> release) {
    final tagName = (release['tag_name'] as String? ?? '').trim();
    if (tagName.isEmpty) return null;

    final assets = (release['assets'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>();
    final asset = assets.cast<Map<String, dynamic>?>().firstWhere(
      (asset) {
        final name = (asset?['name'] as String? ?? '').toLowerCase();
        return name.endsWith('.zip') ||
            name.endsWith('.dmg') ||
            name.endsWith('.pkg');
      },
      orElse: () => null,
    );
    if (asset == null) return null;

    final downloadUrl = asset['browser_download_url'] as String?;
    final fileName = asset['name'] as String?;
    if (downloadUrl == null || fileName == null) return null;

    return UpdateInfo(
      version: _normalizeVersion(tagName),
      downloadUrl: Uri.parse(downloadUrl),
      fileName: fileName,
    );
  }

  @visibleForTesting
  static bool isNewerVersion(String candidate, String current) {
    return _compareVersions(candidate, current) > 0;
  }

  static int _compareVersions(String left, String right) {
    final leftVersion = _ParsedVersion.parse(left);
    final rightVersion = _ParsedVersion.parse(right);

    final mainLength = leftVersion.main.length > rightVersion.main.length
        ? leftVersion.main.length
        : rightVersion.main.length;
    for (var i = 0; i < mainLength; i++) {
      final leftPart = i < leftVersion.main.length ? leftVersion.main[i] : 0;
      final rightPart = i < rightVersion.main.length ? rightVersion.main[i] : 0;
      if (leftPart != rightPart) return leftPart.compareTo(rightPart);
    }

    if (leftVersion.prerelease.isEmpty && rightVersion.prerelease.isNotEmpty) {
      return 1;
    }
    if (leftVersion.prerelease.isNotEmpty && rightVersion.prerelease.isEmpty) {
      return -1;
    }

    final prereleaseLength =
        leftVersion.prerelease.length > rightVersion.prerelease.length
            ? leftVersion.prerelease.length
            : rightVersion.prerelease.length;
    for (var i = 0; i < prereleaseLength; i++) {
      if (i >= leftVersion.prerelease.length) return -1;
      if (i >= rightVersion.prerelease.length) return 1;

      final leftIdentifier = leftVersion.prerelease[i];
      final rightIdentifier = rightVersion.prerelease[i];
      final leftNumber = int.tryParse(leftIdentifier);
      final rightNumber = int.tryParse(rightIdentifier);

      if (leftNumber != null && rightNumber != null) {
        if (leftNumber != rightNumber) return leftNumber.compareTo(rightNumber);
        continue;
      }
      if (leftNumber != null) return -1;
      if (rightNumber != null) return 1;

      final comparison = leftIdentifier.compareTo(rightIdentifier);
      if (comparison != 0) return comparison;
    }

    return 0;
  }
}

class _ParsedVersion {
  final List<int> main;
  final List<String> prerelease;

  const _ParsedVersion({
    required this.main,
    required this.prerelease,
  });

  factory _ParsedVersion.parse(String version) {
    final normalized = UpdateService._normalizeVersion(version);
    final prereleaseSeparatorIndex = normalized.indexOf('-');
    final mainPart = prereleaseSeparatorIndex == -1
        ? normalized
        : normalized.substring(0, prereleaseSeparatorIndex);
    final prereleasePart = prereleaseSeparatorIndex == -1
        ? ''
        : normalized.substring(prereleaseSeparatorIndex + 1);
    final main =
        mainPart.split('.').map((part) => int.tryParse(part) ?? 0).toList();
    final prerelease =
        prereleasePart.isEmpty ? <String>[] : prereleasePart.split('.');

    return _ParsedVersion(main: main, prerelease: prerelease);
  }
}
