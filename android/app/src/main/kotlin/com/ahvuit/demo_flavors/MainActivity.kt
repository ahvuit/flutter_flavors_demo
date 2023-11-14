package com.ahvuit.demo_flavors

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val CHANNEL = "your_channel_name"

    private fun getMessageFromNative(): String = "Hello from native to Flutter!"

    private fun sendMessageToNative(message: String) {
        println("Message from Flutter: $message")
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "flavor").setMethodCallHandler {
            call, result -> result.success(BuildConfig.FLAVOR)
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // This method is invoked on the main thread.
            call, result ->
            if (call.method.equals("getMessageFromNative")) {
                val message = getMessageFromNative()
                result.success(message)
            }
            if (call.method.equals("sendMessageToNative")) {
                val message: String = call.argument("message") ?: ""
                sendMessageToNative(message)
                result.success(null)
             }
            else {
                result.notImplemented()
            }
        }
    }
}
