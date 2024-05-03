import 'package:flutter/material.dart';

class AppConstants {
  static const int defaultFontSize = 24;
  static const Color defaultFontColor = Colors.yellow;
  static const String defaultFontColorHex = '#FFFF00';
  static const TextPosition defaultTextPosition = TextPosition.bottomLeft;
  static const String defaultTextPositionName = "bottomLeft";
  static const String defaultText = "John Doe";
  static const String defaultDirectoryPath = "/storage/emulated/0/DCIM/Camera";
  static const String appIconPath = 'assets/icons/icon_shotby_johndoe.png';
  // static const String defaultDirectoryPath = "/storage/emulated/0/Pictures";
  static const String defaultAppFolderName = "ShotBy - Camera";
  static const String defaultAppFolderPath = "/storage/emulated/0/Pictures";
  static const String defaultFontName = "Roboto";
  static const Color selectedButtonColor = Color.fromARGB(227, 36, 158, 25);
  // Define a list of font sizes for simplicity
  static final fontSizes = [12, 16, 18, 20, 24];
  static const List<String> availableFonts = [
    'Roboto',
    'Dancing Script Regular',
    'Exo 2 Italic',
    // Add your font names here
  ];
  static const Map<int, String> fontSizeLabels = {
    12: 'XS', // Extra Small
    16: 'S', // Small
    18: 'M', // Medium
    20: 'L', // Large
    24: 'XL', // Extra Large
  };

  /// STRINGS
  static const String fontNameKey = 'fontName';
  static const String fontColorHexStringKey = 'fontColorHexString';
  static const String textPositionStringKey = 'textPositionString';
  static const String stampTextKey = 'stampText';
  static const String fontSizeKey = 'fontSize';
}

enum TextPosition { bottomLeft, bottomCenter, bottomRight }

// Function to convert a string to a TextPosition enum value
TextPosition getTextPositionFromString(String positionString) {
  switch (positionString) {
    case 'bottomLeft':
      return TextPosition.bottomLeft;
    case 'bottomCenter':
      return TextPosition.bottomCenter;
    case 'bottomRight':
      return TextPosition.bottomRight;
    default:
      // Return a default value or throw an exception if the string doesn't match any enum value
      return TextPosition.bottomLeft;
  }
}
