import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/providers/photo_provider.dart';
import 'src/providers/stamp_text_provider.dart';
import 'src/services/background_tasks.dart';
import 'src/views/home/home_screen.dart';

///
bool arePermissionsGranted = false; // Declare the global variable
void main() async {
  print("Main function started");
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  // Retrieve the value from SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  arePermissionsGranted = prefs.getBool('permissionsGranted') ?? false;
  await initializeService();
  //
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PhotoProvider>(
          create: (context) => PhotoProvider(),
        ),
        ChangeNotifierProvider<StampTextProvider>(
          create: (context) => StampTextProvider(prefs),
        ),
      ],
      child: //
          MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Stamp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      // home: TestScreen(),
    );
  }
}
