import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/background_tasks.dart';
import '../utils/app_constants.dart';

class StampTextProvider extends ChangeNotifier with WidgetsBindingObserver {
  ///

  int _fontSize = AppConstants.defaultFontSize;
  Color _fontColor = AppConstants.defaultFontColor;
  String _text = AppConstants.defaultText;
  TextPosition _textPosition = AppConstants.defaultTextPosition;
  final SharedPreferences _prefs;
  late final Map<TextPosition, String> formattedTextPositions;
  String _currentFont = 'Roboto';
  final List<String> _availableFonts = [
    'Roboto',
    'DancingScript',
    'Exo2',
    // Add your font names here
  ];
  final TextEditingController textController = TextEditingController();

  /// CONSTRUCTOR ///
  ///
  StampTextProvider(
    this._prefs,
    int initialFontSize,
    Color initialFontColor,
    String initialFontName,
    TextPosition initialTextPosition,
    String initialText,
  ) {
    _fontSize = initialFontSize;
    _fontColor = initialFontColor;
    _currentFont = initialFontName;
    _textPosition = initialTextPosition;
    _text = initialText;
    textController.text = initialText;
    _initAsync();
    _precomputeFormattedTextPositions();
  }
//---------------------------------------------------------------------------------------------------------

  ///
  Future<void> _initAsync() async {
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

//---------------------------------------------------------------------------------------------------------
  //////////////////////////////////////////// GETTERS /////////////////////////////////////////
  int get fontSize => _fontSize;
  Color get fontColor => _fontColor;
  TextPosition get textPosition => _textPosition;
  String get text => _text;
  String get currentFont => _currentFont;
  List<String> get availableFonts => _availableFonts;
  String get fontColorHex => _fontColor.value.toRadixString(16);

  /////////////////////////////////////////// SETTERS /////////////////////////////////////////
  void setFontSize(int newSize) async {
    _fontSize = newSize;
    await _prefs.setInt('fontSize', _fontSize);
    print("Saved fontSize: $_fontSize");
    notifyListeners();
  }

  ///
  void setFontColor(Color newColor) async {
    try {
      _fontColor = newColor;
      // Convert the Color object to a hex color string
      String hexColor = colorToHex(newColor);
      await _prefs.setString('fontColor', hexColor);
      print("Saved fontColor: $hexColor");
      notifyListeners();
    } //
    catch (e) {
      print(e.toString());
    }
  }

  ///
  void setFont(String newFont) async {
    _currentFont = newFont;
    await _prefs.setString('fontName', newFont);
    print("Saved fontName: $newFont");
    notifyListeners();
  }

  ///
  void setText(String newText) async {
    _text = newText;
    await _prefs.setString('text', _text);
    print("Saved text: $_text");
    notifyListeners();
  }

  ///
  void setTextPosition(TextPosition newPosition) async {
    _textPosition = newPosition;
    await _prefs.setString('textPlacement', _textPosition.name);

    print("Setting text position in StampTextProvider: $_textPosition");
    notifyListeners();
  }

  //////////////////////////////////////////// HELPERS /////////////////////////////////////////
  ///
  String formatTextPosition(TextPosition position) {
    // Extract only the part after the dot
    String enumValue = position.toString().split('.').last;
    // Convert camelCase to Title Case
    return enumValue
        .replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'), (Match m) => ' ${m[0]}')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  ///
  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  ///
  void _precomputeFormattedTextPositions() {
    formattedTextPositions = {};
    for (var position in TextPosition.values) {
      formattedTextPositions[position] = formatTextPosition(position);
    }
  }

  ///

  /// CLASS
}
