import 'dart:async';

import 'package:flutter/material.dart';

import '../services/background_tasks.dart';

import 'stamp_text_provider.dart';

///
class PhotoProvider extends ChangeNotifier with WidgetsBindingObserver {
  /// Constructor
  PhotoProvider() {
    _initAsync();
  }

  ///
  Future<void> _initAsync() async {
    try {
      WidgetsBinding.instance.addObserver(this);
      // print('Text Position before requestPermissions = : $_textPosition');

      bool isPermissionGranted = await requestPermissions();
      if (isPermissionGranted) {
        initializePhotoWatcher();
      }
      // print('Text Position after initializePhotoWatcher = : $_textPosition');
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
