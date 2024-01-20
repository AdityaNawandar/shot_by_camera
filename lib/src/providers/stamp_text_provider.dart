import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';

class StampTextProvider extends ChangeNotifier {
  ///
  int _fontSize = AppConstants.fontSize;
  Color _fontColor = AppConstants.fontColor;
  String _text = AppConstants.text;
  TextPosition _textPosition = AppConstants.textPosition;

  // Getter methods
  int get fontSize => _fontSize;
  Color get fontColor => _fontColor;
  TextPosition get textPosition => _textPosition;
  String get text => _text;

  // Setter methodsc
  void setFontSize(int newSize) {
    _fontSize = newSize;
    saveUserPreferences();
    notifyListeners();
  }

  void setFontColor(Color newColor) {
    _fontColor = newColor;
    saveUserPreferences();
    notifyListeners();
  }

  // Setter methods
  void setText(String newText) {
    _text = newText;
    saveUserPreferences();
    notifyListeners();
  }

  void setTextPosition(TextPosition newPosition) {
    _textPosition = newPosition;
    saveUserPreferences();
    print("Setting text position in StampTextProvider: $_textPosition");
    notifyListeners();
  }

  String formatTextPosition(TextPosition position) {
    // Extract only the part after the dot
    String enumValue = position.toString().split('.').last;

    // Convert camelCase to Title Case
    return enumValue
        .replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'), (Match m) => ' ${m[0]}')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Future<void> saveUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fontSize', _fontSize);
    await prefs.setString('fontColor', _fontColor.value.toString());
    await prefs.setString('textPosition', _textPosition.toString());
    await prefs.setString('text', _text);
  }

  ///
}
