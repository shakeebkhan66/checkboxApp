// config.dart

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AppParseConfig {
  static const String parseAppId = '';
  static const String parseServerUrl = '';
  static const String clientKey = '';

  static Future<void> initializeParse() async {
    await Parse().initialize(
      parseAppId,
      parseServerUrl,
      clientKey: clientKey.isNotEmpty ? clientKey : null,
      autoSendSessionId: true,
    );
  }
}