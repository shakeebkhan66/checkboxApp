// info.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          'Info',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'App Name:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          appName.isNotEmpty ? appName : '-',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'App Version:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          appVersion.isNotEmpty ? appVersion : '-',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 16),
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