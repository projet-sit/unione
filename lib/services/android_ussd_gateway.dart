import 'dart:io';

import 'package:flutter/services.dart';

class SimCard {
  final int subscriptionId;
  final String label;
  final String? operatorName;

  const SimCard({
    required this.subscriptionId,
    required this.label,
    this.operatorName,
  });
}

class UssdExecutionResult {
  final bool success;
  final String? response;
  final String? error;

  const UssdExecutionResult({required this.success, this.response, this.error});
}

/// Pont Android vers TelephonyManager.sendUssdRequest (Android 8+).
class AndroidUssdGateway {
  static const _channel = MethodChannel('com.zoli.app/unione_ussd');

  Future<List<SimCard>> getSims() async {
    if (!Platform.isAndroid) return const [];
    try {
      final raw = await _channel.invokeListMethod<Map<dynamic, dynamic>>(
        'getActiveSims',
      );
      return (raw ?? const [])
          .map(
            (sim) => SimCard(
              subscriptionId: sim['subscriptionId'] as int,
              label: sim['label']?.toString() ?? 'Carte SIM',
              operatorName: sim['operatorName']?.toString(),
            ),
          )
          .toList();
    } on PlatformException {
      return const [];
    }
  }

  Future<UssdExecutionResult?> execute(
    String code, {
    int? subscriptionId,
  }) async {
    if (!Platform.isAndroid) return null;
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>(
        'executeUssd',
        {'code': code, 'subscriptionId': subscriptionId},
      );
      if (raw == null) return null;
      return UssdExecutionResult(
        success: raw['success'] == true,
        response: raw['response']?.toString(),
        error: raw['error']?.toString(),
      );
    } on PlatformException catch (error) {
      return UssdExecutionResult(
        success: false,
        error: error.message ?? error.code,
      );
    }
  }
}
