import 'package:flutter/material.dart';
import '../services/background_tasks.dart';
import '../services/preferences_manager.dart';
import '../utils/app_constants.dart';

class StampTextProvider extends ChangeNotifier with WidgetsBindingObserver {
  ///
  final PreferencesManager _prefsManager = PreferencesManager.instance;
  late int _fontSize;
  late Color _fontColor;
  late String _text;
  late TextPosition _textPosition;
  late String _fontName;
  final TextEditingController textController = TextEditingController();

  ///
  StampTextProvider() {
    _loadPreferences();
  }

  ///
  Future<void> _loadPreferences() async {
    try {
      _fontSize = _prefsManager.fontSize;
      _fontColor = _prefsManager.fontColor;
      _textPosition = _prefsManager.textPosition;
      _fontName = _prefsManager.fontName;
      _text = _prefsManager.text;
      textController.text = _text;
      notifyListeners();
    } //
    catch (e) {
      print(e.toString());
    }
  }

  /// FONT SIZE
  int get fontSize => _fontSize;
  set fontSize(int value) {
    _fontSize = value;
    _prefsManager.saveFontSize(value);
    notifyListeners();
  }

  /// FONT COLOR
  Color get fontColor => _fontColor;
  set fontColor(Color value) {
    _fontColor = value;
    _prefsManager.saveFontColor(value);
    notifyListeners();
  }

  /// TEXT
  String get text => _text;
  set text(String value) {
    _text = value;
    _prefsManager.saveText(value);
    notifyListeners();
  }

  /// TEXT POSITION
  TextPosition get textPosition => _textPosition;
  set textPosition(TextPosition value) {
    _textPosition = value;
    _prefsManager.saveTextPosition(_textPosition.name);
    notifyListeners();
  }

  /// FONT NAME
  String get fontName => _fontName;
  set fontName(String value) {
    _fontName = value;
    _prefsManager.saveFont(_fontName);
    notifyListeners();
  }

  ///
  Future<void> initAsync() async {
    try {
      WidgetsBinding.instance.addObserver(this);
      bool isPermissionGranted = await requestPermissions();
      if (isPermissionGranted) {
        initializePhotoWatcher();
      }
    } //
    catch (e) {
      print(e.toString());
    }
  }

  ///
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// CLASS
}
