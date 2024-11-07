// push_installation.dart

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

Future<bool> saveInstallation(String deviceToken, List<String> channels) async {
  final installation = await ParseInstallation.currentInstallation();

  installation.set('deviceToken', deviceToken);
  installation.set('appIdentifier', 'com.standortdigital.flexpush');
  installation.set('channels', channels);

  final response = await installation.save();

  if (!response.success) {
    print('Fehler beim Speichern der Installation: ${response.error?.message}');
    return false;
  } else {
    print('Installation erfolgreich gespeichert');
    return true;
  }
}

Future<List<String>?> fetchUserSettings(String userSettingsObjectId) async {
  final parseObject = ParseObject('UserSettings')..objectId = userSettingsObjectId;
  final ParseResponse response = await parseObject.getObject(userSettingsObjectId);

  if (response.success && response.results != null) {
    final fetchedObject = response.results!.first as ParseObject;
    return fetchedObject.get<List<dynamic>>('topics')?.cast<String>();
  } else {
    print('Fehler beim Abrufen der Benutzereinstellungen: ${response.error?.message}');
    return null;
  }
}

Future<bool> saveUserSettings(String? userSettingsObjectId, String? installationId, List<String> topics) async {
  final parseObject = ParseObject('UserSettings')..objectId = userSettingsObjectId;

  if (installationId != null) {
    parseObject.set('installationId', installationId);
  }
  parseObject.set('topics', topics);

  final ParseResponse response = await parseObject.save();

  if (!response.success) {
    print('Fehler beim Speichern der Benutzereinstellungen: ${response.error?.message}');
    return false;
  } else {
    print('Benutzereinstellungen erfolgreich gespeichert');
    return true;
  }
}