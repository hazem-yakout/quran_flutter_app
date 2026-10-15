package com.example.quran

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

import com.batoulapps.adhan.CalculationMethod
import com.batoulapps.adhan.Coordinates
import com.batoulapps.adhan.Madhab
import com.batoulapps.adhan.PrayerTimes
import com.batoulapps.adhan.data.DateComponents

import java.util.Calendar

object PrayerScheduleManager {

    private const val PREFS = "adhan_preferences"
    private const val KEY_TIMES = "adhan_times"
    private const val KEY_LATITUDE = "adhan_latitude"
    private const val KEY_LONGITUDE = "adhan_longitude"
    private const val KEY_ENABLED = "adhan_enabled"

    private const val REFRESH_REQUEST_CODE = 987654
    private const val DAYS_TO_SCHEDULE = 8
    private const val REFRESH_AFTER_DAYS = 5

    private fun preferences(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    @Synchronized
    fun schedule(
        context: Context,
        latitude: Double,
        longitude: Double
    ): Int {
        require(latitude in -90.0..90.0) {
            "Invalid latitude"
        }
        require(longitude in -180.0..180.0) {
            "Invalid longitude"
        }

        val prefs = preferences(context)

        prefs.edit()
            .putString(KEY_LATITUDE, latitude.toString())
            .putString(KEY_LONGITUDE, longitude.toString())
            .putBoolean(KEY_ENABLED, true)
            .apply()

        cancelPrayerAlarms(context)
        cancelRefreshAlarm(context)

        val now = System.currentTimeMillis()
        val coordinates = Coordinates(latitude, longitude)

        val parameters = CalculationMethod.EGYPTIAN.getParameters()
        parameters.madhab = Madhab.SHAFI

        val timestamps = mutableSetOf<String>()

        for (dayOffset in 0 until DAYS_TO_SCHEDULE) {
            val calendar = Calendar.getInstance()
            calendar.add(Calendar.DAY_OF_YEAR, dayOffset)

            val date = DateComponents(
                calendar.get(Calendar.YEAR),
                calendar.get(Calendar.MONTH) + 1,
                calendar.get(Calendar.DAY_OF_MONTH)
            )

            val prayerTimes = PrayerTimes(
                coordinates,
                date,
                parameters
            )

            val todayTimes = listOf(
                prayerTimes.fajr,
                prayerTimes.dhuhr,
                prayerTimes.asr,
                prayerTimes.maghrib,
                prayerTimes.isha
            )

            for (prayerTime in todayTimes) {
                val timestamp = prayerTime?.time ?: continue

                if (timestamp > now) {
                    AdhanAlarmReceiver.schedule(context, timestamp)
                    timestamps.add(timestamp.toString())
                }
            }
        }

        prefs.edit()
            .putStringSet(KEY_TIMES, timestamps)
            .apply()

        scheduleRefreshAlarm(context)

        return timestamps.size
    }

    @Synchronized
    fun refreshSavedSchedule(context: Context): Int {
        val prefs = preferences(context)

        if (!prefs.getBoolean(KEY_ENABLED, false)) {
            return 0
        }

        val latitude = prefs.getString(KEY_LATITUDE, null)
            ?.toDoubleOrNull() ?: return 0

        val longitude = prefs.getString(KEY_LONGITUDE, null)
            ?.toDoubleOrNull() ?: return 0

        return schedule(context, latitude, longitude)
    }

    @Synchronized
    fun cancelAll(context: Context) {
        val prefs = preferences(context)

        cancelPrayerAlarms(context)
        cancelRefreshAlarm(context)

        prefs.edit()
            .putBoolean(KEY_ENABLED, false)
            .remove(KEY_TIMES)
            .apply()
    }

    private fun cancelPrayerAlarms(context: Context) {
        val prefs = preferences(context)

        val oldTimes = prefs.getStringSet(
            KEY_TIMES,
            emptySet()
        )?.toSet() ?: emptySet()

        oldTimes.forEach { value ->
            value.toLongOrNull()?.let { timestamp ->
                AdhanAlarmReceiver.cancel(context, timestamp)
            }
        }

        prefs.edit()
            .remove(KEY_TIMES)
            .apply()
    }

    private fun scheduleRefreshAlarm(context: Context) {
        val alarmManager = context.getSystemService(
            Context.ALARM_SERVICE
        ) as AlarmManager

        val intent = Intent(
            context,
            AdhanScheduleRefreshReceiver::class.java
        )

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            REFRESH_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or
                    PendingIntent.FLAG_IMMUTABLE
        )

        val triggerAt = System.currentTimeMillis() +
                REFRESH_AFTER_DAYS * 24L * 60L * 60L * 1000L

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerAt,
                pendingIntent
            )
        } else {
            alarmManager.set(
                AlarmManager.RTC_WAKEUP,
                triggerAt,
                pendingIntent
            )
        }
    }

    private fun cancelRefreshAlarm(context: Context) {
        val alarmManager = context.getSystemService(
            Context.ALARM_SERVICE
        ) as AlarmManager

        val intent = Intent(
            context,
            AdhanScheduleRefreshReceiver::class.java
        )

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            REFRESH_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or
                    PendingIntent.FLAG_IMMUTABLE
        )

        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
    }
}
