import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Informations techniques non personnelles jointes aux signalements.
class DeviceInfo {
  final String androidVersion;
  final String model;

  const DeviceInfo({required this.androidVersion, required this.model});
}

/// Lit la version d'Android et le modèle de l'appareil.
///
/// Aucune donnée personnelle n'est collectée : ces informations servent
/// uniquement à reproduire un problème signalé par l'utilisateur.
class DeviceInfoService {
  static const _channel = MethodChannel('com.zoli.app/unione_device');

  Future<DeviceInfo> read() async {
    if (kIsWeb || !Platform.isAndroid) {
      return DeviceInfo(
        androidVersion: kIsWeb ? '' : Platform.operatingSystemVersion,
        model: '',
      );
    }

    try {
      final data = await _channel.invokeMapMethod<String, String>(
        'getDeviceInfo',
      );
      return DeviceInfo(
        androidVersion:
            data?['androidVersion'] ?? Platform.operatingSystemVersion,
        model: data?['model'] ?? '',
      );
    } catch (error) {
      debugPrint('[UNIONE] deviceInfo indisponible: $error');
      return DeviceInfo(
        androidVersion: Platform.operatingSystemVersion,
        model: '',
      );
    }
  }
}
