// push_notification_service.dart

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'push_installation.dart';

Future<void> sendBackgroundNotification(String? deviceToken) async {
  if (deviceToken != null) {
    final parseCloudFunction = ParseCloudFunction('sendMessageNotification');
    final params = {
      'messageContent': 'Die Flex-Push App läuft jetzt im Hintergrund.',
      'deviceToken': deviceToken,
    };
    final ParseResponse result = await parseCloudFunction.execute(parameters: params);

    if (!result.success) {
      print('Fehler beim Senden der Hintergrundbenachrichtigung: ${result.error?.message}');
    } else {
      print('Hintergrundbenachrichtigung erfolgreich gesendet');
    }
  } else {
    print('Kein gültiger Device Token vorhanden.');
  }
}

Future<void> sendForegroundNotification(String? deviceToken, String messageContent) async {
  if (deviceToken != null) {
    final parseCloudFunction = ParseCloudFunction('sendMessageNotification');
    final params = {
      'messageContent': messageContent,
      'deviceToken': deviceToken,
    };
    final ParseResponse result = await parseCloudFunction.execute(parameters: params);

    if (!result.success) {
      print('Fehler beim Senden der Vordergrundbenachrichtigung: ${result.error?.message}');
    } else {
      print('Vordergrundbenachrichtigung erfolgreich gesendet');
    }
  } else {
    print('Kein gültiger Device Token vorhanden.');
  }
}

Future<void> requestNotificationPermissionsAndStartTokenCheck(
    MethodChannel platform,
    {required Function(String) onDeviceTokenReceived,
      required Function onRegistrationSuccess}
    ) async {
  // Berechtigungen anfordern, falls noch nicht erteilt
  if (await Permission.notification.status != PermissionStatus.granted) {
    await Permission.notification.request();
  }

  // Periodische Prüfung des Device Tokens und Registrierung (nur für 60 Sekunden)
  Timer.periodic(Duration(seconds: 1), (timer) async {
    if (timer.tick > 60) {
      timer.cancel(); // Timer nach 60 Sekunden stoppen
    } else {
      try {
        final String? deviceToken = await platform.invokeMethod('getDeviceToken');
        if (deviceToken != null) {
          onDeviceTokenReceived(deviceToken);
          saveInstallation(deviceToken, ['Wetter', 'Werbung']).then((isRegistered) {
            if (isRegistered) {
              timer.cancel(); // Timer stoppen, wenn registriert
              onRegistrationSuccess();
            }
          });
        } else {
          print("Device Token ist null, erneut versuchen.");
        }
      } on PlatformException catch (e) {
        print("Fehler beim Abrufen des Device Tokens: ${e.message}");
      }
    }
  });
}