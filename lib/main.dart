import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/providers/stamp_text_provider.dart';
import 'src/services/background_tasks.dart';
import 'src/services/preferences_manager.dart';

import 'src/views/home/home_screen.dart';

///
bool arePermissionsGranted = false;
void main() async {
  ///
  print("Main function started");
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  // Start background service
  await initializeService();
  // Load user preferences
  await PreferencesManager().loadPreferences();
  // Create and initialize StampTextProvider to start watcher
  StampTextProvider stampTextProvider = StampTextProvider();
  await stampTextProvider.initAsync();

  ///
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<StampTextProvider>(
          create: (context) => StampTextProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

///

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShotBy - Camera',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
