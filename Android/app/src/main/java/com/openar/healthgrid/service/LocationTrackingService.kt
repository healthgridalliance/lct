package com.openar.healthgrid.service

import android.Manifest
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.google.android.gms.location.*
import com.openar.healthgrid.Constants
import com.openar.healthgrid.HealthGridApplication
import com.openar.healthgrid.ui.activity.map.dialog.bottomsheet.ConfigurationBottomSheetDialog
import com.openar.healthgrid.util.PreferenceStorage
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers.Default
import kotlinx.coroutines.launch

class LocationTrackingService : Service() {
    private var fusedLocationClient: FusedLocationProviderClient? = null
    private var locationCallback: LocationCallback? = null
    private var locationRequest: LocationRequest? = null
    private lateinit var localBroadcastManager: LocalBroadcastManager
    private lateinit var broadcastReceiver: StopWorkBroadcastReceiver

    override fun onCreate() {
        localBroadcastManager = LocalBroadcastManager.getInstance(HealthGridApplication.getApplicationContext())
        broadcastReceiver = StopWorkBroadcastReceiver()
        localBroadcastManager.registerReceiver(broadcastReceiver, IntentFilter(ConfigurationBottomSheetDialog.STOP_LOCATION))
        doWork()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun doWork() {
        CoroutineScope(Default).launch {
            configureTracking()
            startLocationUpdates()
        }
    }


    private fun configureTracking() {
        createLocationRequest()
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(HealthGridApplication.getApplicationContext())
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult?) {
                if (locationResult != null) {
                    SaveLocationDataService.instance.saveLocationIfNeeded(locationResult.locations)
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

    private fun startLocationUpdates() {
        if (ActivityCompat.checkSelfPermission(HealthGridApplication.getApplicationContext(), Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
            ActivityCompat.checkSelfPermission(HealthGridApplication.getApplicationContext(), Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            fusedLocationClient?.requestLocationUpdates(
                locationRequest,
                locationCallback,
                Looper.getMainLooper()
            )
            PreferenceStorage.addPropertyBoolean(HealthGridApplication.getApplicationContext(), PreferenceStorage.TRACKING_STARTED_FLAG, true)
            Log.d("LocationApp", "========== REQUEST UPDATES ==========")
        } else {
            stopSelf()
        }

    }

    override fun onDestroy() {
        Log.d("LocationApp", "<><><><><><> STOPPED <><><><><><>")
        PreferenceStorage.addPropertyBoolean(HealthGridApplication.getApplicationContext(), PreferenceStorage.TRACKING_STARTED_FLAG, false)
        fusedLocationClient?.removeLocationUpdates(locationCallback)
        fusedLocationClient = null
        locationCallback = null
        locationRequest = null
    }

    inner class StopWorkBroadcastReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if(intent.action == ConfigurationBottomSheetDialog.STOP_LOCATION) {
                stopSelf()
            }
        }
    }
}