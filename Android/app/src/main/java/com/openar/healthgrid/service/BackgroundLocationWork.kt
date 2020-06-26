package com.openar.healthgrid.service

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Looper
import android.util.Log
import androidx.concurrent.futures.CallbackToFutureAdapter
import androidx.core.app.ActivityCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.work.ListenableWorker
import androidx.work.WorkerParameters
import com.google.android.gms.location.*
import com.google.common.util.concurrent.ListenableFuture
import com.openar.healthgrid.Constants
import com.openar.healthgrid.ui.activity.map.dialog.bottomsheet.ConfigurationBottomSheetDialog
import com.openar.healthgrid.util.PreferenceStorage
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers.Default
import kotlinx.coroutines.launch


class BackgroundLocationWork(private val context: Context, workerParams: WorkerParameters)
    : ListenableWorker(context, workerParams) {
    private var fusedLocationClient: FusedLocationProviderClient? = null
    private var locationCallback: LocationCallback? = null
    private var locationRequest: LocationRequest? = null
    private lateinit var localBroadcastManager: LocalBroadcastManager
    private lateinit var broadcastReceiver: StopWorkBroadcastReceiver

    override fun startWork(): ListenableFuture<Result> {
        return CallbackToFutureAdapter.getFuture { completer ->
            localBroadcastManager = LocalBroadcastManager.getInstance(context)
            broadcastReceiver = StopWorkBroadcastReceiver()
            localBroadcastManager.registerReceiver(broadcastReceiver, IntentFilter(
                ConfigurationBottomSheetDialog.STOP_LOCATION))
                doWork(completer)
        }
    }

    private fun doWork(completer: CallbackToFutureAdapter.Completer<Result>) {
        CoroutineScope(Default).launch {
            if (!isStopped) {
                configureTracking(completer)
                startLocationUpdates(completer)
            }
        }
    }


    private fun configureTracking(completer: CallbackToFutureAdapter.Completer<Result>) {
        createLocationRequest()
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(context)
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult?) {
                if (locationResult != null) {
                    SaveLocationDataService.instance.saveLocationIfNeeded(locationResult.locations)
                    completer.set(Result.success())
                }
            }
        }
    }

    private fun createLocationRequest() {
        locationRequest = LocationRequest.create()?.apply {
            interval = Constants.INTERVAL_MILLIS
            fastestInterval = Constants.FASTEST_INTERVAL_MILLIS
            smallestDisplacement = Constants.MIN_DISPLACEMENT_METER
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        }
    }

    private fun startLocationUpdates(completer: CallbackToFutureAdapter.Completer<Result>) {
        if (ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
            ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            fusedLocationClient?.requestLocationUpdates(
                locationRequest,
                locationCallback,
                Looper.getMainLooper()
            )
            PreferenceStorage.addPropertyBoolean(context, PreferenceStorage.TRACKING_STARTED_FLAG, true)
            Log.d("LocationApp", "========== REQUEST UPDATES ==========")
        } else {
            completer.set(Result.success())
            onStopped()
        }

    }

    override fun onStopped() {
        Log.d("LocationApp", "<><><><><><> STOPPED <><><><><><>")
        fusedLocationClient?.removeLocationUpdates(locationCallback)
        fusedLocationClient = null
        locationCallback = null
        locationRequest = null
        super.onStopped()
    }

    inner class StopWorkBroadcastReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if(intent.action == ConfigurationBottomSheetDialog.STOP_LOCATION) {
                onStopped()
            }
        }
    }

    companion object {
        const val JOB_ID = "BackgroundLocationWork"
    }
}