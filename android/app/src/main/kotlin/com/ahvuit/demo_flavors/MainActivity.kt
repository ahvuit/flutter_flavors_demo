package com.ahvuit.demo_flavors

import android.os.Handler
import android.os.Looper
import android.widget.Toast
import androidx.annotation.NonNull
import com.ahvuit.demo_flavors.models.User
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale


class MainActivity: FlutterActivity() {
    private val CHANNEL = "channel"
    private val EVENT_CHANNEL = "eventChannel"

    private fun getStringFromNative(): String = "Hello from android to Flutter!"

    private fun getUserFromNative(): User {
        return User("123","phuc@gmail.com", "dinn phuc")
    }

    private fun sendMessageToNative(message: User){
        Toast.makeText(applicationContext, "userName: ${message.email}", Toast.LENGTH_LONG).show()
    }

    private fun getCurrentTime(): String {
        return SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(Date()).toString()
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)


        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler{

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    val handler = Handler(Looper.getMainLooper())
                    handler.post(object : Runnable {
                        override fun run() {
                            val currentTime = getCurrentTime()
                            events?.success(currentTime)
                            handler.postDelayed(this, 1000)
                        }
                    })
                }

                override fun onCancel(arguments: Any?) {
                }

            }
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // This method is invoked on the main thread.
            call, result ->
            when (call.method) {
                "getStringFromNative" -> {
                    val message = getStringFromNative()
                    result.success(message)
                }
                "getUserFromNative" -> {
                    val user = getUserFromNative()
                    val message:String = Gson().toJson(user)
                    result.success(message)
                }
                "sendMessageToNative" -> {
                    val message: String = call.argument("message") ?: ""
                    val userData: User = Gson().fromJson(message, User::class.java)
                    sendMessageToNative(userData)
                    //result.success("success")
                }
                else -> { // Note the block
                    result.notImplemented()
                }
            }
        }
    }
}
