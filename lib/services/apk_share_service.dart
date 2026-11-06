import 'dart:io';

import 'package:flutter/services.dart';

/// APK installé, copié dans le cache et prêt à être partagé.
class ApkShareFile {
  final String path;
  final int size;

  const ApkShareFile({required this.path, required this.size});
}

/// Prépare le partage du fichier APK de l'application installée.
///
/// Le fichier est copié depuis `applicationInfo.sourceDir` vers un
/// sous-dossier unique du cache, après vérification de sa signature avec
/// celle de l'application en cours d'exécution.
class ApkShareService {
  static const _channel = MethodChannel('com.zoli.app/unione_apk');

  Future<ApkShareFile> prepare() async {
    if (!Platform.isAndroid) {
      throw const ApkShareUnavailableException(
        'apk_share_unavailable',
        'Le partage du fichier APK est réservé à Android.',
      );
    }

    try {
      final data = await _channel.invokeMapMethod<String, Object?>(
        'prepareApkShare',
      );
      final path = data?['path'] as String?;
      if (path == null || path.isEmpty) {
        throw const ApkShareUnavailableException(
          'apk_share_unavailable',
          'APK installé introuvable.',
        );
      }
      return ApkShareFile(
        path: path,
        size: (data?['size'] as num?)?.toInt() ?? 0,
      );
    } on PlatformException catch (error) {
      throw ApkShareUnavailableException(
        error.code,
        error.message ?? 'Partage de l’APK impossible.',
      );
    }
  }
}

class ApkShareUnavailableException implements Exception {
  final String code;
  final String message;

  const ApkShareUnavailableException(this.code, this.message);

  @override
  String toString() => message;
}
