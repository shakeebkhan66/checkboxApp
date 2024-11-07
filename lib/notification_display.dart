// notification_display.dart

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

void showInAppNotification(String message, BuildContext context) {
  showSimpleNotification(
    Text(
      message,
      style: TextStyle(color: Colors.black),
    ),
    background: Colors.grey[300],
  );
}

void showSuccessSnackbar(String message, BuildContext context, {Duration duration = const Duration(seconds: 5)}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.green,
    duration: duration,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showErrorSnackbar(String message, BuildContext context, {Duration duration = const Duration(seconds: 5)}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.red,
    duration: duration,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}