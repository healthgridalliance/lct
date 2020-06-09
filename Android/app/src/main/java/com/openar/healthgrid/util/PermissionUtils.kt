package com.openar.healthgrid.util

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.IntentSender.SendIntentException
import android.content.pm.PackageManager
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.ResolvableApiException
import com.google.android.gms.location.*
import com.google.android.gms.tasks.Task
import com.openar.healthgrid.ui.activity.map.MapsMainActivity


object PermissionUtils {
    const val REQUEST_CHECK_SETTINGS = 0x1

    fun checkLocationPermission(context: Context): Boolean {
        return if (isPermissionGranted(context, Manifest.permission.ACCESS_FINE_LOCATION)) {
            val backgroundPermissionStatus = ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_BACKGROUND_LOCATION)
            if (backgroundPermissionStatus == PackageManager.PERMISSION_GRANTED) {
                displayLocationSettingsRequest(context)
            } else {
                ActivityCompat.requestPermissions(
                    context as Activity, arrayOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION),
                    MapsMainActivity.BACKGROUND_LOCATION_PERMISSION_REQUEST_CODE
                )
                displayLocationSettingsRequest(context)
            }
        } else {
            ActivityCompat.requestPermissions(
                context as Activity, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_BACKGROUND_LOCATION),
                MapsMainActivity.LOCATION_PERMISSION_REQUEST_CODE
            )
            false
        }
    }

    fun isPermissionGranted(context: Context, permissionType: String): Boolean {
        val permissionStatus = ContextCompat.checkSelfPermission(context, permissionType)
        return permissionStatus == PackageManager.PERMISSION_GRANTED
    }

    private fun displayLocationSettingsRequest(context: Context): Boolean {
        val locationRequest = LocationRequest.create()
        locationRequest.priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        locationRequest.interval = 3000
        locationRequest.fastestInterval = 1000
        val builder = LocationSettingsRequest.Builder().addLocationRequest(locationRequest)
        builder.setAlwaysShow(true)
        val task: Task<LocationSettingsResponse> =
            LocationServices.getSettingsClient(context as Activity)
                .checkLocationSettings(builder.build())
        task.addOnCompleteListener { res ->
            try {
                res.getResult(ApiException::class.java)
            } catch (exception: ApiException) {
                when (exception.statusCode) {
                    LocationSettingsStatusCodes.RESOLUTION_REQUIRED -> {
                        try {
                            val resolvable = exception as ResolvableApiException
                            resolvable.startResolutionForResult(context, REQUEST_CHECK_SETTINGS)
                        } catch (e: SendIntentException) {
                            Log.i("TAG", "PendingIntent unable to execute request.")
                        }
                    }
                }
            }
        }
        return true
    }
}