import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_editor/image_editor.dart' as img_editor;
import 'package:media_scanner/media_scanner.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shotbycamera/src/providers/stamp_text_provider.dart';
import 'package:shotbycamera/src/utils/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watcher/watcher.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;

import '../../main.dart';

///
Directory? photoDirectory = Directory(AppConstants.defaultDirectoryPath);
// Constants
const notificationChannelId = 'image_processing_channel';
const notificationId = 888;

///
Future<void> initializeService() async {
  try {
    final service = FlutterBackgroundService();
    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId, // id
      'ShotBy Camera', // title
      description: 'ShotBy Camera needs to run in the background',
      importance: Importance.high, // Set importance
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    // Create the notification channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: 'ShotBy Camera',
        initialNotificationContent: 'Initializing',
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
      ),
    );
    service.startService();
  } //
  catch (e) {
    print(e.toString());
  }
}

///
void initializePhotoWatcher() async {
  try {
    // Initialize SharedPreferences
    SharedPreferences preferences = await SharedPreferences.getInstance();

    // Retrieve the value from SharedPreferences
    bool arePermissionsGranted =
        preferences.getBool('permissionsGranted') ?? false;

    if (arePermissionsGranted) {
      Directory? photoDirectory = Directory(AppConstants.defaultDirectoryPath);

      if (await photoDirectory.exists()) {
        print("Watching directory: ${AppConstants.defaultDirectoryPath}");
        final watcher = DirectoryWatcher(AppConstants.defaultDirectoryPath);
        final Set<String> processedFiles = {};

        watcher.events.listen((event) {
          if (event.type == ChangeType.ADD &&
              !event.path.contains(".pending")) {
            File file = File(event.path);
            // Check if the file is already being processed before starting the timer
            if (!processedFiles.contains(file.path)) {
              // Debounce mechanism
              Timer(Duration(seconds: 2), () async {
                if (await file.exists() &&
                    !processedFiles.contains(file.path)) {
                  processedFiles.add(file.path);
                  print("Processing file: ${file.path}");

                  /// Retrieve user preferences
                  // font size
                  int fontSize = preferences.getInt('fontSize') ??
                      AppConstants.defaultFontSize;
                  int scaledFontSize = fontSize * 8;
                  // font family
                  String fontName = preferences.getString('fontName') ??
                      AppConstants.defaultFontName;
                  // font color
                  Color fontColor = _getFontColorFromString(preferences);
                  String hexColor = colorToHex(fontColor);
                  // text position
                  String textPositionString =
                      preferences.getString('textPlacement') ??
                          AppConstants.defaultTextPosition.name;
                  TextPosition textPosition = TextPosition.values.firstWhere(
                      (e) => e.name == textPositionString,
                      orElse: () => AppConstants
                          .defaultTextPosition // Default value if not found
                      );
                  // text
                  String text =
                      preferences.getString('text') ?? AppConstants.defaultText;
                  //--------------------PROCESS----------------------//
                  // Proceed with processing
                  print("Processing file: ${file.path}");
                  final service = FlutterBackgroundService();
                  //
                  service.invoke('processImage', {
                    'imagePath': event.path,
                    'fontSize': scaledFontSize,
                    'fontName': fontName,
                    'fontColor': hexColor,
                    'textPosition': textPosition.name,
                    'text': text,
                  });
                  processedFiles.add(file.path);
                  // Process the file (replace with actual processing logic)
                  print("File processed: ${file.path}");
                  // Optionally, remove the file from the set after some time
                  Timer(
                    const Duration(minutes: 10),
                    () => processedFiles.remove(file.path),
                  );
                }
              });
            }
          }
        });
      } //
      else {
        print("Camera directory does not exist or is not accessible");
      }
    } //
    else {
      // Request permissions and wait for them to be granted
      bool permissionsGranted = await requestPermissions();
      if (permissionsGranted) {
        // Permissions were granted, continue with initialization
        photoDirectory = Directory(AppConstants.defaultDirectoryPath);
        // Rest of the code...
      } else {
        // Permissions were not granted, handle accordingly
        print("Need more permissions.");
      }
    }
  } //
  catch (e) {
    print("Error in initializePhotoWatcher: ${e.toString()}");
  }
}

///
Future<void> onStart(ServiceInstance service) async {
  try {
    // Set up listeners for foreground and background state transitions
    if (service is AndroidServiceInstance) {
      service.on('processImage').listen((data) {
        final String imagePath = data?['imagePath'];
        final int fontSize = data?['fontSize'];
        final fontName = data?['fontName'];
        final String? fontColorHex = data?['fontColor'];
        final String text = data?['text'];
        final Color fontColor = _convertStringToColor(fontColorHex);
        final String textPositionString = data?['textPosition'];
        // Convert the string to the TextPosition enum
        final TextPosition textPosition =
            getTextPositionFromString(textPositionString);

        service.setAsForegroundService();
        // Rest of the code to process the image
        processImage(
          imagePath,
          fontSize,
          fontName,
          fontColor,
          textPosition,
          text,
        );
      });
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });
      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }
    service.on('stopService').listen((event) {
      service.stopSelf();
      print('Service STOPPED');
    });
  } //
  catch (e) {
    print('Error in onStart ${e.toString()}');
  }
}

///
Future<void> processImage(
  String imagePath,
  int fontSize,
  String fontName,
  Color fontColor,
  TextPosition textPosition,
  String text,
) async {
  try {
    final File imageFile = File(imagePath);
    if (await imageFile.exists() && !imageFile.path.contains('.pending-')) {
      await addStampToPhoto(
        image: imageFile,
        fontSize: fontSize,
        fontName: fontName,
        text: text,
        fontColor: fontColor,
        textPosition: textPosition,
        photoDirectoryPath: AppConstants.defaultDirectoryPath,
      );
      print('ADDING STAMP...');
    } else {
      print('File does not exist or is a temporary file: $imagePath');
    }
  } catch (e) {
    print('Error in processing file $imagePath: $e');
  }
}

///
Future<void> addStampToPhoto({
  required File image,
  required int fontSize,
  required String fontName,
  required String text,
  required Color fontColor,
  required TextPosition textPosition,
  required String photoDirectoryPath,
}) async {
  ///
  try {
    print("Text: = $text");
    fontName = await registerSelectedFont(fontName);

    final textOption = img_editor.AddTextOption();
    print('Text Position = : $textPosition');
    //
    textOption.addText(
      img_editor.EditorText(
        offset: await calculateOffsetBasedOnPosition(
          textPosition,
          image,
          fontSize,
          text,
        ),
        text: text,
        fontSizePx: fontSize,
        textColor: fontColor,
        fontName: fontName,
      ),
    );
    //
    final options = img_editor.ImageEditorOption()
      ..outputFormat = const img_editor.OutputFormat.jpeg(90);
    options.addOption(textOption);
    //
    print('Edit started @: ${DateTime.now()}');
    //
    final result = await img_editor.ImageEditor.editImage(
      image: image.readAsBytesSync(),
      imageEditorOption: options,
    );
    print('Edit ended @: ${DateTime.now()}');
    // Create or get the "Photo Stamp" directory
    final photoStampDirectoryPath = await getPhotoStampDirectoryPath();
    // Save the stamped image in the "Photo Stamp" directory
    final stampedImage =
        File('$photoStampDirectoryPath/stamped_${basename(image.path)}');
    stampedImage.writeAsBytesSync(result as List<int>);
    print('DONE');
    if (result != null && result.isNotEmpty) {
      print("Image processing successful, size of result: ${result.length}");
    } //
    else {
      print("Image processing failed or returned empty result");
    }
    print("Image stamped, saved at: ${stampedImage.path}");
    MediaScanner.loadMedia(path: stampedImage.path);
    // // To scan a single file
    // // await MediaScanner.scanFile(stampedImage.path);
    // print('Media Scanned');
  } //
  catch (e) {
    print("Error in _addStampToPhoto: $e");
  }
}

///
Future<bool> requestPermissions() async {
  // Define the list of permissions you want to request
  List<Permission> permissionsToRequest = [
    Permission.storage,
    Permission.photos,
    Permission.manageExternalStorage,
    // Add other permissions here
  ];

  try {
    Map<Permission, PermissionStatus> permissionStatuses =
        await permissionsToRequest.request();
    // Check if all requested permissions are granted
    bool allPermissionsGranted = permissionStatuses.values
        .every((status) => status == PermissionStatus.granted);
    if (allPermissionsGranted) {
      print('All permissions granted');
      // Store the value in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('permissionsGranted', true);
    } else {
      // Handle the case where not all permissions are granted
      // You can open app settings to allow the user to manually grant permissions
      print('Not all permissions granted');
    }
    return allPermissionsGranted;
  } //
  catch (e) {
    print('Exception in requestPermissions: ${e.toString()}');
    return false; // Return false in case of an exception
  }
}

////////////////////////////////// HELPER FUNCTIONS /////////////////////////////////////////

///
Future<String> registerSelectedFont(String userSelectedFontFamily) async {
  String assetPath;
  try {
    switch (userSelectedFontFamily) {
      case 'DancingScript':
        assetPath =
            'assets/fonts/Dancing_Script/DancingScript-VariableFont_wght.ttf';
        break;
      case 'Exo2':
        assetPath = 'assets/fonts/Exo_2/Exo2-Italic-VariableFont_wght.ttf';
        break;
      // Add more cases as needed
      default:
        assetPath = 'assets/fonts/Roboto/Roboto-Regular.ttf';
        break;
    }

    String fontFilePath = await getFontFilePath(assetPath);
    String registeredFont =
        await img_editor.FontManager.registerFont(File(fontFilePath));
    return registeredFont;
  } //
  catch (e) {
    print(e.toString());
    return '';
  }
}

///
Future<String> getFontFilePath(String assetPath) async {
  final byteData = await rootBundle.load(assetPath);
  final buffer = byteData.buffer;
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  String fullPath = '$tempPath/${assetPath.split('/').last}';
  File file = File(fullPath);
  await file.writeAsBytes(
      buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  return fullPath;
}

///
String colorToHex(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0')}';
}

///
Color _getFontColorFromString(SharedPreferences prefs) {
  try {
    String fontColorString =
        prefs.getString('fontColor') ?? AppConstants.defaultFontColorHex;

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
      return Color(
        int.parse(AppConstants.defaultFontColorHex.replaceAll('0x', ''),
            radix: 16),
      );
    }
  } //
  catch (e) {
    print(e.toString());
    return Color(int.parse(
        AppConstants.defaultFontColorHex.replaceAll('0x', ''),
        radix: 16));
  }
}

///
Color _convertStringToColor(String? fontColorHex) {
  Color fontColor = AppConstants.defaultFontColor;
  // Check if the string is not null or empty
  if (fontColorHex != null && fontColorHex.isNotEmpty) {
    // Convert the hex string to an integer.
    // The string might start with '#' which should be removed before parsing.
    final String hexValue =
        fontColorHex.startsWith('#') ? fontColorHex.substring(1) : fontColorHex;
    final int fontColorValue = int.parse(hexValue, radix: 16);
    // If your hex string doesn't include alpha value (transparency), you might want to add it.
    // For full opacity, you can use `0xFF` as the high-order bits:
    final int fullOpacityColorValue = 0xFF000000 | fontColorValue;
    // Now you can use this integer to create a Color object, if needed:
    fontColor = Color(fullOpacityColorValue);
  }
  return fontColor;
}

///
Future<Offset> calculateOffsetBasedOnPosition(
    TextPosition position, File imageFile, int fontSize, String text) async {
  try {
    img.Image? image = img.decodeImage(await imageFile.readAsBytes());
    if (image != null) {
      // Calculate margin as a percentage of the image width, for example, 5%
      double marginPercentage = 0.03; // Adjust this value as needed
      double margin =
          image.width * marginPercentage; // Dynamic margin based on image width

      double estimatedCharWidth =
          fontSize * 0.44; // Estimate average character width
      double textWidth =
          estimatedCharWidth * text.length; // Estimate text width

      // Default for left alignment
      double x = margin;

      double subtractionFactor = fontSize * 2;
      // Bottom position with margin
      double y = image.height - subtractionFactor;

      if (position == TextPosition.bottomCenter) {
        x = (image.width / 2) - (textWidth / 2); // Center alignment
      } else if (position == TextPosition.bottomRight) {
        x = image.width -
            textWidth -
            margin * 1; // Right alignment, also consider margin
      }

      // Clamp x value to ensure it's within the image boundaries
      x = x.clamp(0.0, image.width.toDouble() - textWidth);
      print('Text position: $position, Offset: ($x, $y)');
      return Offset(x, y);
    } else {
      throw Exception('Unable to decode image');
    }
  } //
  catch (e) {
    print(' Error in calculateOffsetBasedOnPosition ${e.toString()}');
    return const Offset(0, 0);
  }
}

///
Future<String> getPhotoStampDirectoryPath() async {
  // Get the external storage directory
  var dir = Directory(
      '${(Platform.isAndroid ? await getExternalStorageDirectory() //FOR ANDROID
              : await getApplicationSupportDirectory() //FOR IOS
          )!.path}/${AppConstants.defaultAppFolderName}');
  String newPath = "";
  //
  List<String> paths = dir.path.split("/");
  for (int x = 1; x < paths.length; x++) {
    String folder = paths[x];
    if (folder != "Android") {
      newPath += "/$folder";
    } else {
      break;
    }
  }
  newPath = "$newPath/Pictures/${AppConstants.defaultAppFolderName}";
  // Check if the directory exists
  dir = Directory(newPath);
  if (!await dir.exists()) {
    // If the directory does not exist, create it
    // await requestPermissions();
    await dir.create(recursive: true);
  }
  return newPath;
}
