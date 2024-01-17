import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../services/background_tasks.dart';
import '../utils/app_constants.dart';
import 'stamp_text_provider.dart';

///
class PhotoProvider extends ChangeNotifier with WidgetsBindingObserver {
  // Initialize with default values

  // Map<String, Timer> _debounceMap = {};
  int _fontSize = AppConstants.fontSize;
  Color _fontColor = AppConstants.fontColor;
  String _text = AppConstants.text;
  TextPosition _textPosition = TextPosition.bottomLeft;

  /// Constructor
  PhotoProvider() {
    _initAsync();
  }

  ///
  Future<void> _initAsync() async {
    try {
      WidgetsBinding.instance.addObserver(this);
      print('Text Position before requestPermissions = : $_textPosition');

      bool isPermissionGranted = await requestPermissions();
      if (isPermissionGranted) {
        initializePhotoWatcher();
      }
      print('Text Position after initializePhotoWatcher = : $_textPosition');
    } catch (e) {
      print(e.toString());
    }
  }

  ///
  void updateFromStampTextProvider(StampTextProvider stampProvider) {
    try {
      _fontSize = stampProvider.fontSize;
      _fontColor = stampProvider.fontColor;
      _text = stampProvider.text;
      _textPosition = stampProvider.textPosition;

      print("Updated text position in PhotoProvider: $_textPosition");
      // Call any methods that need to react to these changes
    } catch (e) {
      print(e.toString());
    }
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     // App is resumed - perform actions related to your provider
  //     // _initializePhotoWatcher();
  //   }
  // }

  ///
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  ///
}
