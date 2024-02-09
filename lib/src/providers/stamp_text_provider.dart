import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

class StampTextProvider extends ChangeNotifier {
  ///

  int _fontSize = AppConstants.fontSize;
  Color _fontColor = AppConstants.fontColor;
  String _text = AppConstants.text;
  TextPosition _textPosition = AppConstants.textPosition;
  final SharedPreferences _prefs;
  late final Map<TextPosition, String> formattedTextPositions;

  ///
  StampTextProvider(this._prefs) {
    // SharedPreferences.setMockInitialValues({});
    _precomputeFormattedTextPositions();
  }

  ///
  void _precomputeFormattedTextPositions() {
    formattedTextPositions = {};
    for (var position in TextPosition.values) {
      formattedTextPositions[position] = formatTextPosition(position);
    }
  }

  /// GETTERS
  int get fontSize => _fontSize;
  Color get fontColor => _fontColor;
  TextPosition get textPosition => _textPosition;
  String get text => _text;

  String get fontColorHex => _fontColor.value.toRadixString(16);

  /// SETTERS
  void setFontSize(int newSize) async {
    _fontSize = newSize;
    await _prefs.setInt('fontSize', _fontSize);
    notifyListeners();
  }

  ///
  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  ///
  void setFontColor(Color newColor) async {
    try {
      _fontColor = newColor;
      // Convert the Color object to a hex color string
      String hexColor = colorToHex(newColor);
      await _prefs.setString('fontColor', hexColor);
      notifyListeners();
    } //
    catch (e) {
      print(e.toString());
    }
  }

  ///
  void setText(String newText) async {
    _text = newText;
    await _prefs.setString('text', _text);
    notifyListeners();
  }

  ///
  void setTextPosition(TextPosition newPosition) async {
    _textPosition = newPosition;
    await _prefs.setString('textPlacement', _textPosition.name);
    // await _prefs.reload();
    print("Setting text position in StampTextProvider: $_textPosition");
    notifyListeners();
  }

  ///
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

  ///
}
