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
  static final Uri _latestReleaseUrl = Uri.https(
    'api.github.com',
    '/repos/parisnakitakejser/kids-memory-trainer/releases/latest',
  );

  Future<UpdateInfo?> checkForUpdate() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(_latestReleaseUrl);
      request.headers
          .set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      request.headers.set(HttpHeaders.userAgentHeader, 'kids-memory-trainer');

      final response = await request.close();
      if (response.statusCode == HttpStatus.notFound) return null;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const HttpException('GitHub release check failed');
      }

      final body = await utf8.decodeStream(response);
      final json = jsonDecode(body) as Map<String, dynamic>;
      final tagName = (json['tag_name'] as String? ?? '').trim();
      final latestVersion = _normalizeVersion(tagName);
      if (!_isNewerVersion(latestVersion, currentVersion)) return null;

      final assets = (json['assets'] as List<dynamic>? ?? [])
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
        version: latestVersion,
        downloadUrl: Uri.parse(downloadUrl),
        fileName: fileName,
      );
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

  static bool _isNewerVersion(String candidate, String current) {
    final candidateParts = _versionParts(candidate);
    final currentParts = _versionParts(current);
    final length = candidateParts.length > currentParts.length
        ? candidateParts.length
        : currentParts.length;

    for (var i = 0; i < length; i++) {
      final candidatePart = i < candidateParts.length ? candidateParts[i] : 0;
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      if (candidatePart > currentPart) return true;
      if (candidatePart < currentPart) return false;
    }

    return false;
  }

  static List<int> _versionParts(String version) {
    return version
        .split(RegExp(r'[.-]'))
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
  }
}
