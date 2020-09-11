import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_switchable_theme/config.dart';

extension StringToThemeModeExtension on String {
  ThemeMode get toThemeMode {
    try {
      return ThemeMode.values.firstWhere((mode) => mode.configString == this);
    } on StateError {
      debugPrint("Invalid ThemeMode enum string: " + this);
      return ThemeMode.system;
    }
  }
}

extension ThemeModeToStringExtension on ThemeMode {
  String get configString {
    return this.toString().split(".").elementAt(1);
  }
}

class SwitchableTheme with ChangeNotifier {
  ThemeMode _currentMode;

  SwitchableTheme() {
    if (configBox.containsKey('currentTheme')) {
      _currentMode = configBox.get('currentTheme').toString().toThemeMode;
    } else {
      configBox.put('currentTheme', ThemeMode.system.configString);
    }
  }

  bool isDark() {
    ThemeMode themeMode = configBox.get('currentTheme').toString().toThemeMode;
    switch (themeMode) {
      case ThemeMode.system:
        return SchedulerBinding.instance.window.platformBrightness ==
            Brightness.dark;
        break;
      case ThemeMode.light:
        return false;
        break;
      case ThemeMode.dark:
        return true;
        break;
      default:
        return false;
        break;
    }
  }

  ThemeMode currentMode() {
    return _currentMode;
  }

  void switchTheme() {
    ThemeMode mode;
    switch (_currentMode) {
      case ThemeMode.system:
        mode = isDark() ? ThemeMode.light : ThemeMode.dark;
        break;
      case ThemeMode.light:
        mode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        mode = ThemeMode.light;
        break;
      default:
        mode = isDark() ? ThemeMode.light : ThemeMode.dark;
        break;
    }
    configBox.put('currentTheme', mode.configString);
    _currentMode = mode;
    notifyListeners();
  }

  void switchTo(String theme) {
    ThemeMode mode;
    switch (theme) {
      case "system":
        mode = ThemeMode.system;
        break;
      case "light":
        mode = ThemeMode.dark;
        break;
      case "dark":
        mode = ThemeMode.light;
        break;
      default:
        // When we don't know the theme, we cycle through the themes.

        // Otherwise, we can't have any idea how to behave other than crash.
        switchTheme();
        return;
        break;
    }
    configBox.put('currentTheme', mode.configString);
    _currentMode = mode;
    notifyListeners();
  }
}
