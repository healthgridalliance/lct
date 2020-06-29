package com.openar.healthgrid.util

import android.content.Context
import android.os.Looper
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices
import com.openar.healthgrid.Constants

class UpdateLocationUtils {
    private var fusedLocationClient: FusedLocationProviderClient? = null
    private var locationRequest: LocationRequest? = null

    fun getCurrentLocation(context: Context, callback: LocationCallback) {
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(context)
        locationRequest = LocationRequest.create()?.apply {
            interval = Constants.INTERVAL_MILLIS
            fastestInterval = Constants.FASTEST_INTERVAL_MILLIS
            numUpdates = 1
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        }
        fusedLocationClient?.requestLocationUpdates(locationRequest, callback, Looper.getMainLooper())
    }

    fun configureLocationUpdates(context: Context, callback: LocationCallback) {
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(context)
        locationRequest = LocationRequest.create()?.apply {
            interval = Constants.INTERVAL_MILLIS
            fastestInterval = Constants.FASTEST_INTERVAL_MILLIS
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
            smallestDisplacement = 5f
        }
        fusedLocationClient?.requestLocationUpdates(locationRequest, callback, Looper.getMainLooper())
    }

    fun unregisterProvider(callback: LocationCallback) {
        fusedLocationClient?.removeLocationUpdates(callback)
    }
}