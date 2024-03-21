import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';
import '../utils/utilities.dart';

class PreferencesManager extends ChangeNotifier {
  late SharedPreferences _prefs;
  late int fontSize;
  late Color fontColor;
  late String fontName;
  late TextPosition textPosition;
  late String text;
  late String fontColorString;
  late String textPositionString;

  PreferencesManager._privateConstructor();

  static final PreferencesManager _instance =
      PreferencesManager._privateConstructor();

  factory PreferencesManager() {
    return _instance;
  }
  // Static getter for the instance
  static PreferencesManager get instance => _instance;

  Future<void> loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    fontSize =
        _prefs.getInt(AppConstants.fontSizeKey) ?? AppConstants.defaultFontSize;
    fontColorString = _prefs.getString(AppConstants.fontColorHexStringKey) ??
        AppConstants.defaultFontColorHex;
    fontColor = getColorFromString(fontColorString);
    fontName = _prefs.getString(AppConstants.fontNameKey) ??
        AppConstants.defaultFontName;
    textPositionString = _prefs.getString(AppConstants.textPositionStringKey) ??
        AppConstants.defaultTextPositionName;
    textPosition = getTextPositionFromString(textPositionString);
    text =
        _prefs.getString(AppConstants.stampTextKey) ?? AppConstants.defaultText;

    print(text);
  }

  /// FONT SIZE
  Future<void> saveFontSize(int fontSize) async {
    await _prefs.setInt(AppConstants.fontSizeKey, fontSize);
    print("Saved fontSize: $fontSize");
  }

  Future<int> getFontSize() async {
    int fontSize =
        _prefs.getInt(AppConstants.fontSizeKey) ?? AppConstants.defaultFontSize;
    return fontSize;
  }

  /// FONT COLOR
  Future<void> saveFontColor(Color color) async {
    String colorString = colorToHexString(color);
    await _prefs.setString(AppConstants.fontColorHexStringKey, colorString);
    print("Saved fontColor: $colorString");
  }

  Future<Color> getFontColor() async {
    String fontColorString =
        _prefs.getString(AppConstants.fontColorHexStringKey) ??
            AppConstants.defaultFontColorHex;
    Color fontColor = getColorFromString(fontColorString);
    return fontColor;
  }

  /// TEXT
  Future<void> saveText(String text) async {
    await _prefs.setString(AppConstants.stampTextKey, text);
    print("Saved text: $text");
  }

  Future<String> getText() async {
    String text =
        _prefs.getString(AppConstants.stampTextKey) ?? AppConstants.defaultText;
    return text;
  }

  /// TEXT POSITION
  Future<void> saveTextPosition(String textPositionString) async {
    await _prefs.setString(
      AppConstants.textPositionStringKey,
      textPositionString,
    );
    print("Setting text position in StampTextProvider: $textPositionString");
  }

  Future<TextPosition> getTextPosition() async {
    String textPositionString =
        _prefs.getString(AppConstants.textPositionStringKey) ??
            AppConstants.defaultTextPositionName;
    TextPosition textPosition = getTextPositionFromString(textPositionString);
    return textPosition;
  }

  /// FONT FAMILY
  Future<void> saveFont(String fontNameString) async {
    await _prefs.setString(AppConstants.fontNameKey, fontNameString);
  }

  Future<String> getFontName() async {
    String fontNameString = _prefs.getString(AppConstants.fontNameKey) ??
        AppConstants.defaultFontName;
    return fontNameString;
  }

  /// Class
}
