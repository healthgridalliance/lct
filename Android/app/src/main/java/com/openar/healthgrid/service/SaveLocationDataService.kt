package com.openar.healthgrid.service

import android.location.Location
import android.util.Log
import com.openar.healthgrid.Constants
import com.openar.healthgrid.HealthGridApplication
import com.openar.healthgrid.R
import com.openar.healthgrid.database.LocationInfoEntity
import com.openar.healthgrid.database.LocationInfoProvider
import com.openar.healthgrid.repository.ApiRequestsRepository
import com.openar.healthgrid.util.DateUtils
import com.openar.healthgrid.util.PreferenceStorage
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class SaveLocationDataService private constructor() {
    private val locationProvider: LocationInfoProvider? = LocationInfoProvider.instance

    private object HOLDER {
        val INSTANCE = SaveLocationDataService()
    }

    companion object {
        val instance: SaveLocationDataService by lazy { HOLDER.INSTANCE }
    }

    fun saveLocationIfNeeded(locations: List<Location>) {
        var lastSavedLocation: Location? = getLastSavedLocation()
        for (newLocation in locations) {
            Log.d("LocationApp", "${newLocation.latitude}    ${newLocation.longitude}   =>=>=>=>  ${DateUtils.getDate(newLocation.time)}\n\n")
            if(lastSavedLocation != null) {
                if (checkMinDistance(lastSavedLocation, newLocation)) {
                    updateLastObjectCheckOutTime(newLocation.time)
//                    sendLastLocationIfNeeded()
                    writeToDatabase(createDatabaseObject(newLocation))
                    lastSavedLocation = newLocation
                }
            } else {
                // table is empty
                writeToDatabase(createDatabaseObject(newLocation))
                lastSavedLocation = newLocation
            }
        }
        Log.d("LocationApp", "__________________________________________________________")
    }

    fun deleteAllData() {
        CoroutineScope(Dispatchers.Default).launch {
            locationProvider?.deleteAllData()
        }
    }

    private fun getLastSavedLocation(): Location? {
        val lastSavedLocation: LocationInfoEntity? = locationProvider?.getLastObject()
        lastSavedLocation?.let {
            val location = Location("")
            location.latitude = lastSavedLocation.latitude.toDouble()
            location.longitude = lastSavedLocation.longitude.toDouble()
            return location
        }
        return null
    }

    private fun checkMinDistance(prev: Location, cur: Location): Boolean {
        val distanceMeters: Float = prev.distanceTo(cur)
        return distanceMeters > Constants.MIN_DISPLACEMENT_METER
    }

    fun updateLastObjectCheckOutTime(time: Long) {
        locationProvider?.updateLastObjectCheckoutTime(DateUtils.getTimeStamp(time))
    }

//    private fun sendLastLocationIfNeeded() {
//        val context = HealthGridApplication.getApplicationContext()
//        val status = PreferenceStorage.getPropertyInt(context, PreferenceStorage.HEALTH_STATUS_VALUE)
//        if (status == R.id.radio_infected) {
//            val locationObject = locationProvider?.getLastObject()
//            locationObject?.let { ApiRequestsRepository().sendLocation(it) }
//        }
//    }

    private fun writeToDatabase(locationObject: LocationInfoEntity) {
        locationProvider?.saveLocation(locationObject)
    }

    private fun createDatabaseObject(location: Location, checkOutTime: Long? = null): LocationInfoEntity {
        // TODO replace hardcoded appId with real
        return LocationInfoEntity(
            DateUtils.getTimeStamp(location.time),
            checkOutTime?.let { DateUtils.getTimeStamp(it) } ?: "",
            DateUtils.getDate(location.time),
            location.latitude.toString(),
            location.longitude.toString()
        )
    }
}