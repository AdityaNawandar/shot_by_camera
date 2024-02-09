import 'package:flutter/material.dart';

class AppConstants {
  static const int fontSize = 60;
  static const Color fontColor = Colors.yellow;
  static const String fontColorHex = '#FFFF00';
  static const TextPosition textPosition = TextPosition.bottomLeft;
  static const String text = "Shot By Aditya Nawandar";
  static const String directoryPath = "/storage/emulated/0/DCIM/Camera";
  static const String appFolderName = "ShotByCamera";
  static const String appFolderPath = "/storage/emulated/0/Pictures";
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
      return TextPosition
          .bottomCenter; // Or throw Exception('Invalid text position string: $positionString');
  }
}
