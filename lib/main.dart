// main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart'; // Import für Parse

import 'config.dart'; // Stellen Sie sicher, dass dies korrekt importiert ist
import 'custom_header.dart'; // Header in einer separaten Datei
import 'bottom_nav_bar.dart'; // Menüleiste in einer separaten Datei
import 'push_installation.dart'; // Push Installation in separater Datei
import 'push_notification_service.dart'; // Push Benachrichtigungsdienst in separater Datei
import 'notification_display.dart'; // Anzeige von Benachrichtigungen in separater Datei
import 'info.dart'; // Info-Widget in einer separaten Datei
import 'info_bottom_sheet.dart'; // Importiere die Bottom-Sheet-Anzeige

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ParseServer initialisieren
  await AppParseConfig.initializeParse();

  runApp(
    OverlaySupport.global(
      child: MyApp(parseServerUrl: AppParseConfig.parseServerUrl),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String parseServerUrl;

  MyApp({required this.parseServerUrl});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ihre App',
      home: CheckboxExample(parseServerUrl: parseServerUrl),
    );
  }
}

class CheckboxExample extends StatefulWidget {
  final String parseServerUrl;

  CheckboxExample({required this.parseServerUrl});

  @override
  _CheckboxExampleState createState() => _CheckboxExampleState();
}

class _CheckboxExampleState extends State<CheckboxExample>
    with WidgetsBindingObserver {
  static const platform = MethodChannel('com.standortdigital.flexpush/deviceToken');

  bool _wetterChecked = false;
  bool _werbungChecked = false;
  AppLifecycleState? _lastLifecycleState;

  DateTime? _lastBackgroundTime;
  DateTime? _lastForegroundTime;

  String appName = '';
  String appVersion = '';

  String? _userSettingsObjectId;
  String? _deviceToken;
  String? _installationId;
  bool _isRegistered = false;
  Timer? _snackbarTimer;
  bool _isSnackbarVisible = false;
  BuildContext? _bottomSheetContext;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAppInfo();

    // Berechtigungen anfordern und Token-Prüfung starten
    _requestNotificationPermissionsAndStartTokenCheckWrapper();
    _loadCheckboxStates().then((_) => _fetchUserSettings());
  }

  Future<void> _requestNotificationPermissionsAndStartTokenCheckWrapper() async {
    await requestNotificationPermissionsAndStartTokenCheck(
      platform,
      onDeviceTokenReceived: (token) async {
        setState(() {
          _deviceToken = token;
        });

        // Abrufen der aktuellen Installation und Setzen der installationId
        final installation = await ParseInstallation.currentInstallation();
        setState(() {
          _installationId = installation.installationId;
        });
      },
      onRegistrationSuccess: () {
        setState(() {
          _isRegistered = true;
        });
      },
    );
  }

  void _loadAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appName = packageInfo.appName;
      appVersion = packageInfo.version;
    });
  }

  @override
  void dispose() {
    _snackbarTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_lastLifecycleState != state) {
      if (state == AppLifecycleState.resumed) {
        // App kommt in den Vordergrund
        _updateForegroundTime();
        showInAppNotification('Die App ist nun wieder im Vordergrund', context);
      } else if (state == AppLifecycleState.paused) {
        // App geht in den Hintergrund
        _updateBackgroundTime();
        sendBackgroundNotification(_deviceToken); // Hintergrundbenachrichtigung senden

        // Schließe das Bottom Sheet, falls es geöffnet ist
        if (_bottomSheetContext != null) {
          Navigator.of(_bottomSheetContext!).pop();
          _bottomSheetContext = null;
        }
      }
      _lastLifecycleState = state;
    }
  }

  void _updateForegroundTime() {
    setState(() {
      _lastForegroundTime = DateTime.now();
    });
  }

  void _updateBackgroundTime() {
    setState(() {
      _lastBackgroundTime = DateTime.now();
    });
  }

  void _saveCheckboxStates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wetterChecked', _wetterChecked);
    await prefs.setBool('werbungChecked', _werbungChecked);
  }

  Future<void> _loadCheckboxStates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _wetterChecked = prefs.getBool('wetterChecked') ?? false;
      _werbungChecked = prefs.getBool('werbungChecked') ?? false;
      _userSettingsObjectId = prefs.getString('userSettingsObjectId');
    });
  }

  Future<void> _fetchUserSettings() async {
    if (_userSettingsObjectId != null) {
      final userSettings = await fetchUserSettings(_userSettingsObjectId!);
      if (userSettings != null) {
        setState(() {
          _wetterChecked = userSettings.contains('Wetter');
          _werbungChecked = userSettings.contains('Werbung');
        });
      }
    }
  }

  Future<void> _saveUserSettings() async {
    List<String> topics = [];
    if (_wetterChecked) {
      topics.add('Wetter');
    }
    if (_werbungChecked) {
      topics.add('Werbung');
    }
    bool success = await saveUserSettings(_userSettingsObjectId, _installationId, topics);
    if (success) {
      _showSuccessSnackbar('Benutzereinstellungen erfolgreich gespeichert.');
    } else {
      _showErrorSnackbar('Fehler beim Speichern der Benutzereinstellungen.');
    }
  }

  void _handleCheckboxChange(bool? newValue, String topic) async {
    setState(() {
      if (topic == 'Wetter') {
        _wetterChecked = newValue ?? false;
      } else if (topic == 'Werbung') {
        _werbungChecked = newValue ?? false;
      }
    });

    // Benutzereinstellungen und Checkbox-Zustände speichern
    if (_installationId != null) {
      await _saveUserSettings();
      _saveCheckboxStates();

      // Installation aktualisieren, um die Channels zu aktualisieren
      List<String> channels = [];
      if (_wetterChecked) {
        channels.add('Wetter');
      }
      if (_werbungChecked) {
        channels.add('Werbung');
      }
      if (_deviceToken != null) {
        saveInstallation(_deviceToken!, channels);
      }
    } else {
      print('installationId ist null und kann nicht gespeichert werden.');
    }
  }

  void _showSuccessSnackbar(String message) {
    if (_isSnackbarVisible) {
      _snackbarTimer?.cancel();
    } else {
      _isSnackbarVisible = true;
      final snackBar = SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    _snackbarTimer = Timer(Duration(seconds: 5), () {
      _isSnackbarVisible = false;
    });
  }

  void _showErrorSnackbar(String message) {
    if (_isSnackbarVisible) {
      _snackbarTimer?.cancel();
    } else {
      _isSnackbarVisible = true;
      final snackBar = SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    _snackbarTimer = Timer(Duration(seconds: 5), () {
      _isSnackbarVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        appName: appName,
        appVersion: appVersion,
        lastBackgroundTime: _lastBackgroundTime,
        lastForegroundTime: _lastForegroundTime,
        parseServerUrl: widget.parseServerUrl,
        deviceToken: _deviceToken,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Buttons über die volle Breite
          children: <Widget>[
            CheckboxListTile(
              title: Text("Wetter"),
              value: _wetterChecked,
              onChanged: (bool? newValue) {
                _handleCheckboxChange(newValue, 'Wetter');
              },
            ),
            CheckboxListTile(
              title: Text("Werbung"),
              value: _werbungChecked,
              onChanged: (bool? newValue) {
                _handleCheckboxChange(newValue, 'Werbung');
              },
            ),
            Expanded(child: Container()),
            Text(
              '$appName · Version $appVersion',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}