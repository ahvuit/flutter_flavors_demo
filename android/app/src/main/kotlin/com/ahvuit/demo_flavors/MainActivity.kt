package com.ahvuit.demo_flavors

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.widget.Toast
import androidx.annotation.NonNull
import com.ahvuit.demo_flavors.models.User
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import com.google.gson.Gson

class MainActivity: FlutterActivity() {
    private val CHANNEL = "channel"

    private fun getMessageFromNative(): String = "Hello from native to Flutter!"

    private fun sendMessageToNative(message: User){
        println("Message from Flutter: $message")
        Toast.makeText(applicationContext, message.email, Toast.LENGTH_LONG).show()
    }

    private fun getBatteryLevel(): Int {
        val batteryLevel: Int = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(
                Intent.ACTION_BATTERY_CHANGED))
            intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }

        return batteryLevel
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // This method is invoked on the main thread.
            call, result ->
            when (call.method) {
                "getMessageFromNative" -> {
                    val message = getMessageFromNative()
                    result.success(message)
                }
                "sendMessageToNative" -> {
                    val message: String = call.argument("message") ?: ""
                    val userData: User = Gson().fromJson(message, User::class.java)
                    sendMessageToNative(userData)
                    result.success(null)
                }
                "getBatteryLevel" -> {
                    val batteryLevel = getBatteryLevel()

                    if (batteryLevel != -1) {
                        result.success(batteryLevel)
                    } else {
                        result.error("UNAVAILABLE", "Battery level not available.", null)
                    }
                }
                else -> { // Note the block
                    result.notImplemented()
                }
            }
        }
    }
}
