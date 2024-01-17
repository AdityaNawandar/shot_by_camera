// background_tasks.dart
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_editor/image_editor.dart' as img_editor;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_stamp/src/utils/app_constants.dart';
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
  // DartPluginRegistrant.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // Set up listeners for foreground and background state transitions
  if (service is AndroidServiceInstance) {
    service.on('processImage').listen((data) {
      final String imagePath = data?['imagePath'];
      // Rest of the code to process the image
      processImage(imagePath);
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
  // // Periodically check for new images to process
  // Timer.periodic(const Duration(seconds: 1), (timer) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String? imagePath = prefs.getString('newImagePath');
  //   if (imagePath != null) {
  //     processImage(imagePath);
  //     prefs.remove('newImagePath');
  //   }
  // Update foreground notification (only for Android)
  // if (service is AndroidServiceInstance &&
  //     await service.isForegroundService()) {
  //   flutterLocalNotificationsPlugin.show(
  //     notificationId,
  //     'Image Stamping Service',
  //     'Processing images in background',
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         notificationChannelId,
  //         'IMAGE STAMPING SERVICE',
  //         icon: 'ic_bg_service_small',
  //         ongoing: true,
  //       ),
  //     ),
  //   );
  // }
  // });
}

///
void processImage(String imagePath) async {
  try {
    final File imageFile = File(imagePath);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Retrieve user preferences
    int fontSize = prefs.getInt('fontSize') ?? AppConstants.fontSize;
    int scaledFontSize = fontSize * 2;
    final Color fontColor = _getFontColorFromString(prefs);
    String textPositionString =
        prefs.getString('textPosition') ?? AppConstants.textPosition.toString();
    TextPosition textPosition = TextPosition.values
        .firstWhere((e) => e.toString() == textPositionString);
    String text = prefs.getString('text') ?? AppConstants.text;
    // Check if the file exists and is not a temporary file
    if (await imageFile.exists() && !imageFile.path.contains('.pending-')) {
      // Call the function to add a stamp to the photo
      await addStampToPhoto(
        image: imageFile,
        fontSize: scaledFontSize,
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

Color _getFontColorFromString(prefs) {
  String fontColorString =
      prefs.getString('fontColor') ?? AppConstants.fontColor.toString();
  Color fontColor = AppConstants.fontColor;
  if (fontColorString.contains('(0x')) {
    final hexColorString = fontColorString.split('(0x')[1].split(')')[0];
    final validHexColorString =
        hexColorString.length == 8 ? hexColorString : 'FF' + hexColorString;
    fontColor = Color(int.parse(validHexColorString, radix: 16));
  } else {
    // Use the default color
    fontColor = AppConstants.fontColor;
  }
  return fontColor;
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
  newPath = "$newPath/Pictures/Photo_Stamp";
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
    TextPosition position, File imageFile, int fontSize) async {
  img.Image? image = img.decodeImage(await imageFile.readAsBytes());
  if (image != null) {
    double x = 20; // Default for left alignment
    double subtrationFactor = fontSize * 2.5;
    double y = image.height - subtrationFactor; // Bottom position with margin
    if (position == TextPosition.bottomCenter) {
      x = (image.width / 2) - (fontSize * 2); // Adjust for center alignment
    } //
    else if (position == TextPosition.bottomRight) {
      x = image.width - fontSize * 10; // Adjust for right alignment
    }
    return Offset(x, y);
  } else {
    throw Exception('Unable to decode image');
  }
}

///
void initializePhotoWatcher() async {
  try {
    // Initialize SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Retrieve the value from SharedPreferences
    bool arePermissionsGranted = prefs.getBool('permissionsGranted') ?? false;
    //
    if (arePermissionsGranted) {
      photoDirectory = Directory(AppConstants.directoryPath);
      //
      if (await photoDirectory?.exists() ?? false) {
        final watcher = DirectoryWatcher(photoDirectory!.path); //
        print("DirectoryWatcher created for path: ${photoDirectory!.path}");
        watcher.events.listen((event) {
          print("Event detected: ${event.toString()}");
          if (event.type == ChangeType.ADD &&
              !event.path.contains("stamped_")) {
            print("Scheduling processing for file: ${event.path}");
            final service = FlutterBackgroundService();
            service.invoke('processImage', {'imagePath': event.path});
          }
        });
      } //
      else {
        print("Camera directory does not exist or is not accessible");
      }
    } //
    else {
      requestPermissions();
      print("Need more permissions.");
    }
  } //
  catch (e) {
    print(e.toString());
  }
}

///
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Create notification channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    'IMAGE STAMPING SERVICE', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.low, // Set importance
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

///Function to request storage permissions
Future<bool> requestPermissions() async {
  bool arePermissionsGranted = false;
  // Define the list of permissions you want to request
  List<Permission> permissionsToRequest = [
    Permission.storage,
    Permission.photos,
    Permission.manageExternalStorage,
    // Add other permissions here
  ];
  //
  try {
    Map<Permission, PermissionStatus> permissionStatuses =
        await permissionsToRequest.request();
    // Check if all requested permissions are granted
    bool allPermissionsGranted = permissionStatuses.values
        .every((status) => status == PermissionStatus.granted);
    //
    if (allPermissionsGranted) {
      arePermissionsGranted = true;
      print('All permissions granted');
      // Store the value in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('permissionsGranted', true);
    } else {
      // Handle the case where not all permissions are granted
      // You can open app settings to allow the user to manually grant permissions
      print('Not all permissions granted');
      await openAppSettings();
    }
  } catch (e) {
    print('Exception in requestPermissions: ${e.toString()}');
  }

  print('Permission granted: $arePermissionsGranted');
  return arePermissionsGranted;
}
