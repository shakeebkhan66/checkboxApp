//custom_header.dart

import 'package:flutter/material.dart';
import 'info_bottom_sheet.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String appName;
  final String appVersion;
  final DateTime? lastBackgroundTime;
  final DateTime? lastForegroundTime;
  final String? parseServerUrl;
  final String? deviceToken;

  CustomHeader({
    required this.appName,
    required this.appVersion,
    this.lastBackgroundTime,
    this.lastForegroundTime,
    this.parseServerUrl,
    this.deviceToken,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      title: Text(
        'Flex-Push',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.info_outline,
            color: Colors.white,
          ),
          onPressed: () {
            // Info-Button Aktion
            showInfoBottomSheet(
              context,
              appName,
              appVersion,
              lastBackgroundTime,
              lastForegroundTime,
              parseServerUrl,
              deviceToken,
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}