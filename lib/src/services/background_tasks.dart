import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_editor/image_editor.dart' as img_editor;
import 'package:media_scanner/media_scanner.dart';
// import 'package:media_scanner/media_scanner.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:shotbycamera/src/utils/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watcher/watcher.dart';
import 'package:image/image.dart' as img;

///
Directory? photoDirectory = Directory(AppConstants.directoryPath);

// Constants
const notificationChannelId = 'image_processing_channel';
const notificationId = 888;

///
Future<void> onStart(ServiceInstance service) async {
  try {
    // Set up listeners for foreground and background state transitions
    if (service is AndroidServiceInstance) {
      service.on('processImage').listen((data) {
        final String imagePath = data?['imagePath'];
        final int fontSize = data?['fontSize'];
        final String? fontColorHex = data?['fontColor'];
        final Color fontColor = _convertStringToColor(fontColorHex);
        final String textPositionString = data?['textPosition'];
        // Convert the string to the TextPosition enum
        final TextPosition textPosition =
            getTextPositionFromString(textPositionString);
        final String text = data?['text'];
        service.setAsForegroundService();
        // Rest of the code to process the image
        processImage(imagePath, fontSize, fontColor, textPosition, text);
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
    });
  } //
  catch (e) {
    print(e.toString());
  }
}

///
Color _convertStringToColor(String? fontColorHex) {
  Color fontColor = AppConstants.fontColor;
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
void processImage(
  String imagePath,
  int fontSize,
  Color fontColor,
  TextPosition textPosition,
  String text,
) async {
  try {
    // SharedPreferences.setMockInitialValues({});
    final File imageFile = File(imagePath);

    // Check if the file exists and is not a temporary file
    if (await imageFile.exists() && !imageFile.path.contains('.pending-')) {
      // Call the function to add a stamp to the photo
      await addStampToPhoto(
        image: imageFile,
        fontSize: fontSize,
        text: text,
        fontColor: fontColor,
        textPosition: textPosition,
        photoDirectoryPath: AppConstants.directoryPath,
      );
    } else {
      // Log and handle the situation, perhaps by retrying later
      print('File does not exist or is a temporary file: $imagePath');
    }
  } //
  catch (e) {
    print('Error in processing file $imagePath: $e');
    // Optionally implement a retry mechanism or other error handling
  }
}

///
Color _getFontColorFromString(SharedPreferences prefs) {
  try {
    String fontColorString =
        prefs.getString('fontColor') ?? AppConstants.fontColorHex;

    // Remove any '#' symbol if present
    fontColorString = fontColorString.replaceAll('#', '');

    // Check if the string length is 6 (without alpha) or 8 (with alpha)
    if (fontColorString.length == 6 || fontColorString.length == 8) {
      // Add 'FF' as alpha if it's not present
      if (fontColorString.length == 6) {
        fontColorString = 'FF' + fontColorString;
      }

      // Parse the hex color string
      Color fontColor = Color(int.parse(fontColorString, radix: 16));
      return fontColor;
    } //
    else {
      // Handle the case where the format is invalid
      return Color(
          int.parse(AppConstants.fontColorHex.replaceAll('0x', ''), radix: 16));
    }
  } //
  catch (e) {
    print(e.toString());
    return Color(
        int.parse(AppConstants.fontColorHex.replaceAll('0x', ''), radix: 16));
  }
}

///
Future<void> addStampToPhoto({
  required File image,
  required int fontSize,
  required String text,
  required Color fontColor,
  required TextPosition textPosition,
  required String photoDirectoryPath,
}) async {
  ///
  try {
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
        fontName: '',
        // Use a registered font name or leave empty for default system font
      ),
    );
    //
    final options = img_editor.ImageEditorOption()
      ..outputFormat = img_editor.OutputFormat.jpeg(75);
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
    if (result != null && result.isNotEmpty) {
      print("Image processing successful, size of result: ${result.length}");
      reinitializeWatcher(
        fontSize: fontSize,
        text: text,
        fontColor: fontColor,
        textPosition: textPosition,
      );
    } //
    else {
      print("Image processing failed or returned empty result");
    }
    print("Image stamped, saved at: ${stampedImage.path}");
    MediaScanner.loadMedia(path: stampedImage.path);
    // To scan an entire directory
    // await MediaScanner.scanDirectory(
    //     '${AppConstants.appFolderPath}/${AppConstants.appFolderName}');
    // To scan a single file
    // await MediaScanner.scanFile(stampedImage.path);
    print('Media Scanned');
  } //
  catch (e) {
    print("Error in _addStampToPhoto: $e");
  }
}

///
Future<String> getPhotoStampDirectoryPath() async {
  // Get the external storage directory
  var dir = Directory(
      '${(Platform.isAndroid ? await getExternalStorageDirectory() //FOR ANDROID
              : await getApplicationSupportDirectory() //FOR IOS
          )!.path}/${AppConstants.appFolderName}');
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
  newPath = "$newPath/Pictures/${AppConstants.appFolderName}";
  // Check if the directory exists
  dir = Directory(newPath);
  if (!await dir.exists()) {
    // If the directory does not exist, create it
    // await requestPermissions();
    await dir.create(recursive: true);
  }
  return newPath;
}

///
Future<Offset> calculateOffsetBasedOnPosition(
    TextPosition position, File imageFile, int fontSize, String text) async {
  img.Image? image = img.decodeImage(await imageFile.readAsBytes());
  if (image != null) {
    double margin = 120; // Margin from edges
    double estimatedCharWidth =
        fontSize * 0.5; // Estimate average character width
    double textWidth = estimatedCharWidth * text.length; // Estimate text width
    // Default for left alignment
    double x = margin;
    double subtrationFactor = fontSize * 2;
    // Bottom position with margin
    double y = image.height - subtrationFactor;
    if (position == TextPosition.bottomCenter) {
      x = (image.width / 2) - (textWidth / 2); // Center alignment
    } //
    else if (position == TextPosition.bottomRight) {
      x = image.width - textWidth - 100; // Right alignment
    }
    // Clamp x value to ensure it's within the image boundaries
    x = x.clamp(0.0, image.width - textWidth);
    print('Text position: $position, Offset: ($x, $y)');
    return Offset(x, y);
  } else {
    throw Exception('Unable to decode image');
  }
}

/// Function to initialize photo watcher
void initializePhotoWatcher() async {
  try {
    // Initialize SharedPreferences
    SharedPreferences preferences = await SharedPreferences.getInstance();

    // Retrieve the value from SharedPreferences
    bool arePermissionsGranted =
        preferences.getBool('permissionsGranted') ?? false;

    if (arePermissionsGranted) {
      Directory? photoDirectory = Directory(AppConstants.directoryPath);

      if (await photoDirectory.exists()) {
        final watcher = DirectoryWatcher(photoDirectory.path);
        print("DirectoryWatcher created for path: ${photoDirectory.path}");
        watcher.events.listen((event) async {
          print("Event detected: ${event.toString()}");
          if (event.type == ChangeType.ADD &&
              !event.path.contains("stamped_") &&
              !event.path.contains(".pending")) {
            print('in for EVENT ${event.type}');
            // Verify the file still exists before processing
            File file = File(event.path);
            if (await file.exists()) {
              print("Scheduling processing for file: ${event.path}");
              // Retrieve user preferences
              int fontSize =
                  preferences.getInt('fontSize') ?? AppConstants.fontSize;
              int scaledFontSize = fontSize * 2;
              // Retrieve and log font color
              Color fontColor = _getFontColorFromString(preferences);
              String hexColor = colorToHex(fontColor);
              // Logging the hex color string
              print("Font color in hex format: $hexColor");
              // Retrieve text position
              String textPositionString =
                  preferences.getString('textPlacement') ??
                      AppConstants.textPosition.name;
              TextPosition textPosition = TextPosition.values.firstWhere(
                  (e) => e.name == textPositionString,
                  orElse: () =>
                      AppConstants.textPosition // Default value if not found
                  );
              String text = preferences.getString('text') ?? AppConstants.text;

              final service = FlutterBackgroundService();
              service.invoke('processImage', {
                'imagePath': event.path,
                'fontSize': scaledFontSize,
                'fontColor': hexColor,
                'textPosition': textPosition.name,
                'text': text,
              });
              // Proceed with processing
            } else {
              print("File no longer exists, skipping: ${event.path}");
            }
          }
        });
      } else {
        print("Camera directory does not exist or is not accessible");
      }
    } else {
      // Request permissions and wait for them to be granted
      bool permissionsGranted = await requestPermissions();
      if (permissionsGranted) {
        // Permissions were granted, continue with initialization
        photoDirectory = Directory(AppConstants.directoryPath);
        // Rest of the code...
      } else {
        // Permissions were not granted, handle accordingly
        print("Need more permissions.");
      }
    }
  } catch (e) {
    print("Error in initializePhotoWatcher: ${e.toString()}");
  }
}

// Helper method to convert Color object to hex string (if not already defined)
String colorToHex(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0')}';
}

///
Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  // Create notification channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    'IMAGE STAMPING SERVICE', // title
    description: 'This channel is used for important notifications.',
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
      initialNotificationTitle: 'Image Stamping Service',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
    ),
  );
  var sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.reload(); // Its important
  service.startService();
}

///
void reinitializeWatcher({
  int? fontSize,
  String? text,
  Color? fontColor,
  TextPosition? textPosition,
}) async {
  if (await photoDirectory?.exists() ?? false) {
    print("Photo directory exists: ${photoDirectory?.path}");
    // Reinitialize the watcher
    initializePhotoWatcher();
  }
}

/// Function to request storage permissions
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
    return allPermissionsGranted; // Return the result
  } catch (e) {
    print('Exception in requestPermissions: ${e.toString()}');
    return false; // Return false in case of an exception
  }
}
