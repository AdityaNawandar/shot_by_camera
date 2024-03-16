import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/providers/stamp_text_provider.dart';
import 'src/services/background_tasks.dart';
import 'src/utils/app_constants.dart';
import 'src/views/home/home_screen.dart';

///
bool arePermissionsGranted = false; // Declare the global variable
void main() async {
  print("Main function started");
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  // SharedPreferences.setMockInitialValues({}); // Use only for tests
  await initializeService();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve the values from SharedPreferences
  // bool arePermissionsGranted = prefs.getBool('permissionsGranted') ?? false;
  int fontSize = prefs.getInt('fontSize') ?? AppConstants.defaultFontSize;
  String fontColorString =
      prefs.getString('fontColor') ?? AppConstants.defaultFontColorHex;
  Color fontColor = _getFontColorFromString(
      fontColorString); // Implement this method as before
  String fontName = prefs.getString('fontName') ?? AppConstants.defaultFontName;
  String textPositionString =
      prefs.getString('textPlacement') ?? AppConstants.defaultTextPosition.name;
  TextPosition textPosition = TextPosition.values.firstWhere(
      (e) => e.name == textPositionString,
      orElse: () => AppConstants.defaultTextPosition);
  String text = prefs.getString('text') ?? AppConstants.defaultText;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<StampTextProvider>(
          create: (context) => StampTextProvider(
            prefs,
            fontSize,
            fontColor,
            fontName,
            textPosition,
            text,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

///
Color _getFontColorFromString(String fontColorString) {
  // Implement the logic to convert color string to Color object
  // Remove any '#' symbol if present
  fontColorString = fontColorString.replaceAll('#', '');

  // Check if the string length is 6 (without alpha) or 8 (with alpha)
  if (fontColorString.length == 6 || fontColorString.length == 8) {
    // Add 'FF' as alpha if it's not present
    if (fontColorString.length == 6) {
      fontColorString = 'FF$fontColorString';
    }

    // Parse the hex color string
    Color fontColor = Color(int.parse(fontColorString, radix: 16));
    return fontColor;
  } //
  else {
    // Handle the case where the format is invalid
    return Color(int.parse(
        AppConstants.defaultFontColorHex.replaceAll('0x', ''),
        radix: 16));
  }
  // return Color(int.parse(colorString, radix: 16)).withOpacity(1.0);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Stamp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
