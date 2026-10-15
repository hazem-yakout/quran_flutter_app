
package com.example.quran

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class AdhanScheduleRefreshReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        PrayerScheduleManager.refreshSavedSchedule(context)
    }
}
