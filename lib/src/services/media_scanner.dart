// import 'package:flutter/services.dart';

// class MediaScanner {
//   ///
//   static const MethodChannel _channel = MethodChannel('media_scanner');

//   static Future<void> scanFile(String filePath) async {
//     await _channel.invokeMethod('scanFile', {'filePath': filePath});
//   }

//   static Future<void> scanDirectory(String directoryPath) async {
//     print('Invoking scanDirectory with path: $directoryPath');
//     await _channel
//         .invokeMethod('scanDirectory', {'directoryPath': directoryPath});
//     print('Method invoked');
//   }

//   ///
// }
