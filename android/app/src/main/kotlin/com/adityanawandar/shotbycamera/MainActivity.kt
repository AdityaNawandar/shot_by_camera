package com.adityanawandar.shotbycamera
import android.util.Log
import android.media.MediaScannerConnection
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File


class MainActivity: FlutterActivity() {    
     val CHANNEL = "media_scanner"
///
override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        .setMethodCallHandler { call, result ->
            Log.d("MethodChannel", "Method called: ${call.method}")
            when (call.method) {
                "scanFile" -> {
                    val filePath = call.argument<String>("filePath")
                    filePath?.let {
                        MediaScannerConnection.scanFile(this, arrayOf(filePath), null) { _, _ ->
                            result.success(null)
                        }
                    } ?: result.error("INVALID_PATH", "Invalid file path", null)
                }
                "scanDirectory" -> {
                    try {
                        val directoryPath = call.argument<String>("directoryPath")
                        Log.d("MethodChannel", "Scanning directory: $directoryPath")
                        directoryPath?.let {
                            scanDirectory(directoryPath)
                            result.success(null)
                        } ?: result.error("INVALID_PATH", "Invalid directory path", null)
                    } catch (e: Exception) {
                        Log.e("MethodChannel", "Error scanning directory", e)
                        result.error("ERROR", "Error scanning directory", e.localizedMessage)
                    }
                }
                else -> result.notImplemented()
            }
        }
}
///
    private fun scanDirectory(path: String) {
        val directory = File(path)
        val files = directory.listFiles()
        files?.forEach { file ->
            if (file.isFile) {
                MediaScannerConnection.scanFile(this, arrayOf(file.absolutePath), null, null)
            }
        }
    }
}