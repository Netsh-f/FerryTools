import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  final Function(bool) onToggleTheme;
  final ThemeMode currentThemeMode;

  const SettingPage({
    super.key,
    required this.onToggleTheme,
    required this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark;
    switch (currentThemeMode) {
      case ThemeMode.dark:
        isDark = true;
        break;
      case ThemeMode.light:
      default:
        isDark = false;
        break;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          SwitchListTile(
            title: const Text('深色主题'),
            subtitle: const Text('开启后界面将变为深色'),
            value: currentThemeMode == ThemeMode.dark,
            onChanged: (bool value) {
              onToggleTheme(value);
            },
            secondary: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}