package com.openar.healthgrid.util

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.work.*
import com.openar.healthgrid.Constants
import com.openar.healthgrid.service.BackgroundLocationWork
import com.openar.healthgrid.service.DeleteExpiredDataWork
import com.openar.healthgrid.service.StartJobAfterDelay
import java.util.concurrent.TimeUnit

object WorkUtils {
    fun startBackgroundJob(context: Context) {
        if (checkConstraints(context)) {
            val workRequest: PeriodicWorkRequest = PeriodicWorkRequest
                .Builder(BackgroundLocationWork::class.java, 15, TimeUnit.MINUTES)
                .addTag(BackgroundLocationWork.JOB_ID)
                .build()
            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                BackgroundLocationWork.JOB_ID,
                ExistingPeriodicWorkPolicy.KEEP,
                workRequest
            )
        }
    }

    private fun checkConstraints(context: Context): Boolean {
        return ((ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
                        ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) &&
                        PreferenceStorage.getPropertyInt(context, PreferenceStorage.TRACKING_STATUS_VALUE) == Constants.ACTIVE_TRACKING_STATUS &&
                        !PreferenceStorage.getPropertyBooleanFalse(context, PreferenceStorage.TRACKING_STARTED_FLAG))
    }

    fun stopUniqueJob(context: Context, id: String) {
        WorkManager.getInstance(context).cancelUniqueWork(id)
    }

     fun configureCheckExpiredDataJob(context: Context) {
        val workRequest: PeriodicWorkRequest = PeriodicWorkRequest
            .Builder(DeleteExpiredDataWork::class.java, Constants.CHECK_EXPIRED_DATA_INTERVAL_HOURS, TimeUnit.HOURS)
            .addTag(DeleteExpiredDataWork.JOB_ID)
            .build()
        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            DeleteExpiredDataWork.JOB_ID,
            ExistingPeriodicWorkPolicy.KEEP,
            workRequest
        )
    }

    fun scheduleTurnOnTrackingAfterTime(context: Context, minutes: Long) {
        val workRequest: OneTimeWorkRequest = OneTimeWorkRequest
            .Builder(StartJobAfterDelay::class.java)
            .setInitialDelay(minutes, TimeUnit.MINUTES)
            .addTag(StartJobAfterDelay.JOB_ID)
            .build()
        WorkManager.getInstance(context).enqueueUniqueWork(
            StartJobAfterDelay.JOB_ID,
            ExistingWorkPolicy.KEEP,
            workRequest
        )
    }
}