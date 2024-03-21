import 'package:flutter/material.dart';

import 'app_constants.dart';

String colorToHexString(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0')}';
}

Color getColorFromString(String? colorString) {
  Color fontColor = AppConstants.defaultFontColor;
  // Check if the string is not null or empty
  if (colorString != null && colorString.isNotEmpty) {
    // Convert the hex string to an integer.
    // The string might start with '#' which should be removed before parsing.
    final String hexValue =
        colorString.startsWith('#') ? colorString.substring(1) : colorString;
    final int fontColorValue = int.parse(hexValue, radix: 16);
    // If your hex string doesn't include alpha value (transparency), you might want to add it.
    // For full opacity, you can use `0xFF` as the high-order bits:
    final int fullOpacityColorValue = 0xFF000000 | fontColorValue;
    // Now you can use this integer to create a Color object, if needed:
    fontColor = Color(fullOpacityColorValue);
  }
  return fontColor;
}

// TextPosition getTextPositionFromString(String positionString) {
//   // Implement the method to get TextPosition from string
//   return TextPosition.values.firstWhere(
//     (e) => e.name == positionString,
//     orElse: () => AppConstants.defaultTextPosition,
//   );
// }
