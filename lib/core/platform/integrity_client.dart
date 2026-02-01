import 'package:flutter/services.dart';

class IntegrityClient {
  static const _ch = MethodChannel('com.obj.sire/integrity');

  static Future<Map<String, dynamic>> requestToken() async {
    final res = await _ch.invokeMethod('requestIntegrityToken');
    return Map<String, dynamic>.from(res as Map);
  }
}
