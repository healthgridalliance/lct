package com.openar.healthgrid.service


import android.Manifest
import android.content.Context
import android.os.Bundle
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.openar.healthgrid.Constants
import com.openar.healthgrid.util.BroadcastUtils
import com.openar.healthgrid.util.PermissionUtils
import com.openar.healthgrid.util.PreferenceStorage
import com.openar.healthgrid.util.WorkUtils
import kotlinx.coroutines.coroutineScope

class StartJobAfterDelay(private val context: Context, workerParams: WorkerParameters) :
    CoroutineWorker(context, workerParams) {

    override suspend fun doWork(): Result = coroutineScope{
        if(PermissionUtils.isPermissionGranted(context, Manifest.permission.ACCESS_FINE_LOCATION)) {
            PreferenceStorage.addPropertyBoolean(context, PreferenceStorage.NEED_ACTIVATE_TRACKING, true)
            PreferenceStorage.addPropertyInt(context, PreferenceStorage.TRACKING_STATUS_VALUE, Constants.ACTIVE_TRACKING_STATUS)
            WorkUtils.startLocationTracking(context)
            createLocalBroadcast()
            Log.d("LocationApp", "*************** AFTER DELAY ***************")
        }
        Result.success()
    }

    private fun createLocalBroadcast() {
        val extras = Bundle()
        extras.putInt(TRACKING_MODE, Constants.ACTIVE_TRACKING_STATUS)
        BroadcastUtils.sendBroadcast(context, BROADCAST_ACTION, extras)
//        Intent().also { intent ->
//            intent.action = BROADCAST_ACTION
//            intent.putExtra(TRACKING_MODE, Constants.ACTIVE_TRACKING_STATUS)
//            LocalBroadcastManager.getInstance(context).sendBroadcast(intent)
//        }
    }

    companion object {
        const val TRACKING_MODE = "TRACKING_MODE"
        const val BROADCAST_ACTION = "com.openar.healthgrid.TRACKING_MODE_CHANGED"
        const val JOB_ID = "29"
    }
}