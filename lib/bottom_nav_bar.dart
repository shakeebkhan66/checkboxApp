import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Push Nachrichten',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Einstellungen',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: 'Info',
        ),
      ],
      onTap: (index) {
        // Aktion für den ausgewählten Menüpunkt
        switch (index) {
          case 0:
          // Home Aktion
            break;
          case 1:
          // Push Nachrichten Aktion
            break;
          case 2:
          // Einstellungen Aktion
            break;
          case 3:
          // Info Aktion
            break;
        }
      },
    );
  }
}