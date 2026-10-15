
package com.example.quran

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.example.quran/adhan"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "scheduleAdhan" -> {
                    val latitude = call.argument<Number>("latitude")
                    val longitude = call.argument<Number>("longitude")

                    if (latitude == null || longitude == null) {
                        result.error(
                            "INVALID_COORDINATES",
                            "Latitude and longitude are required.",
                            null
                        )
                    } else {
                        try {
                            val count = PrayerScheduleManager.schedule(
                                applicationContext,
                                latitude.toDouble(),
                                longitude.toDouble()
                            )
                            result.success(count)
                        } catch (exception: Exception) {
                            result.error(
                                "SCHEDULE_FAILED",
                                exception.message,
                                null
                            )
                        }
                    }
                }

                "cancelAdhan" -> {
                    PrayerScheduleManager.cancelAll(applicationContext)

                    stopService(
                        Intent(
                            applicationContext,
                            AdhanPlaybackService::class.java
                        )
                    )

                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }
}
