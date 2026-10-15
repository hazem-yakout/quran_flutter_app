package com.example.quran

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class AdhanBootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        if (
            intent?.action != Intent.ACTION_BOOT_COMPLETED &&
            intent?.action != Intent.ACTION_MY_PACKAGE_REPLACED
        ) {
            return
        }

        val preferences = context.getSharedPreferences(
            "adhan_preferences",
            Context.MODE_PRIVATE
        )

        val savedTimes = preferences.getStringSet("adhan_times", emptySet())
            ?.toList()
            ?: emptyList()

        val now = System.currentTimeMillis()

        savedTimes
            .mapNotNull { it.toLongOrNull() }
            .filter { it > now }
            .distinct()
            .forEach { timestamp ->
                try {
                    AdhanAlarmReceiver.schedule(context, timestamp)
                } catch (e: Exception) {
                    Log.e(
                        "AdhanBootReceiver",
                        "Failed to schedule adhan alarm",
                        e
                    )
                }
            }
    }
}