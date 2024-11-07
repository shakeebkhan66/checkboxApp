//info_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Für Clipboard

void showInfoBottomSheet(
    BuildContext context,
    String appName,
    String appVersion,
    DateTime? lastBackgroundTime,
    DateTime? lastForegroundTime,
    String? parseServerUrl,
    String? deviceToken) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // Transparent, damit der Hintergrund wie gewünscht sichtbar ist
    builder: (BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white, // Weiß ohne Transparenz für den Inhalt
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
        child: FractionallySizedBox(
          heightFactor: 0.5, // Maximale Höhe auf 50% des Bildschirms begrenzt
          widthFactor: 1.0, // Volle Breite des Bildschirms
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: InfoWidget(
              appName: appName,
              appVersion: appVersion,
              lastBackgroundTime: lastBackgroundTime,
              lastForegroundTime: lastForegroundTime,
              parseServerUrl: parseServerUrl,
              deviceToken: deviceToken,
            ),
          ),
        ),
      );
    },
  );
}

class InfoWidget extends StatelessWidget {
  final String appName;
  final String appVersion;
  final DateTime? lastBackgroundTime;
  final DateTime? lastForegroundTime;
  final String? parseServerUrl;
  final String? deviceToken;

  InfoWidget({
    required this.appName,
    required this.appVersion,
    this.lastBackgroundTime,
    this.lastForegroundTime,
    this.parseServerUrl,
    this.deviceToken,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Letzter Hintergrundmodus:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          lastBackgroundTime != null ? _formatDateTime(lastBackgroundTime!) : '-',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Letzter App-Start:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          lastForegroundTime != null ? _formatDateTime(lastForegroundTime!) : '-',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 16),
        if (parseServerUrl != null)
          Text(
            'Parse Server URL:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (parseServerUrl != null)
          Text(
            parseServerUrl!,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        SizedBox(height: 16),
        if (deviceToken != null && deviceToken!.isNotEmpty)
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: deviceToken!));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Device Token in die Zwischenablage kopiert'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300], // Hintergrundfarbe Hellgrau
              foregroundColor: Colors.black, // Schriftfarbe Schwarz
              minimumSize: Size(double.infinity, 48), // Volle Breite
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // Eckiger Button
              ),
            ),
            child: Text('Device Token kopieren'),
          ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_addLeadingZero(dateTime.day)}.${_addLeadingZero(dateTime.month)}.${dateTime.year} ${_addLeadingZero(dateTime.hour)}:${_addLeadingZero(dateTime.minute)}:${_addLeadingZero(dateTime.second)}';
  }

  String _addLeadingZero(int value) {
    return value.toString().padLeft(2, '0');
  }
}
