package com.openar.healthgrid.service


import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.openar.healthgrid.Constants
import com.openar.healthgrid.database.LocationInfoProvider
import kotlinx.coroutines.coroutineScope

class DeleteExpiredDataWork(context: Context, workerParams: WorkerParameters) :
    CoroutineWorker(context, workerParams) {

    override suspend fun doWork(): Result = coroutineScope{
        if (!isStopped) {
            LocationInfoProvider.instance?.deleteExpiredData(Constants.KEEP_MAX_HOURS)
        }
        Result.success()
    }

    companion object {
        const val JOB_ID = "27"
    }
}