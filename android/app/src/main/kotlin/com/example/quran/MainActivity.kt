package com.example.quran

import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.example.quran/adhan"
    private val prefsName = "adhan_preferences"
    private val timesKey = "adhan_times"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "scheduleAdhan" -> {
                    val times = call.argument<List<Number>>("times")

                    if (times == null) {
                        result.error(
                            "INVALID_TIMES",
                            "Missing prayer timestamps",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    val prefs = getSharedPreferences(
                        prefsName,
                        Context.MODE_PRIVATE
                    )

                    // Cancel all previously scheduled adhan alarms.
                    val oldTimes = prefs.getStringSet(
                        timesKey,
                        emptySet()
                    )?.mapNotNull { it.toLongOrNull() }.orEmpty()

                    oldTimes.forEach { timestamp ->
                        AdhanAlarmReceiver.cancel(this, timestamp)
                    }

                    // Keep only future prayer times.
                    val futureTimes = times
                        .map { it.toLong() }
                        .filter { it > System.currentTimeMillis() }
                        .distinct()

                    // Schedule the new alarms.
                    futureTimes.forEach { timestamp ->
                        AdhanAlarmReceiver.schedule(this, timestamp)
                    }

                    prefs.edit()
                        .putStringSet(
                            timesKey,
                            futureTimes.map { it.toString() }.toSet()
                        )
                        .apply()

                    result.success(futureTimes.size)
                }

                "cancelAdhan" -> {
                    val prefs = getSharedPreferences(
                        prefsName,
                        Context.MODE_PRIVATE
                    )

                    val scheduledTimes = prefs.getStringSet(
                        timesKey,
                        emptySet()
                    )?.mapNotNull { it.toLongOrNull() }.orEmpty()

                    scheduledTimes.forEach { timestamp ->
                        AdhanAlarmReceiver.cancel(this, timestamp)
                    }

                    prefs.edit().remove(timesKey).apply()

                    stopService(
                        Intent(this, AdhanPlaybackService::class.java)
                    )

                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }
}