// loading_screen.dart

import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hintergrundfarbe kann angepasst werden
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(), // Ladeindikator
      ),
    );
  }
}