package com.openar.healthgrid.repository

import android.location.Location
import com.openar.healthgrid.Constants
import com.openar.healthgrid.HealthGridApplication
import com.openar.healthgrid.api.entity.HeatMapObject
import com.openar.healthgrid.database.LocationInfoEntity
import com.openar.healthgrid.database.LocationInfoProvider
import com.openar.healthgrid.util.PreferenceStorage
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class CheckExposureRepository(private val infectedCoordinates: HeatMapObject) {
    private var exposureCount = 0
    private var curMaxExposureDistance = Constants.MAX_DISTANCE_EXPOSURE_METER

    fun checkExposure(callback: (pair: Pair<String, Int>) -> Unit) {
        CoroutineScope(Dispatchers.Default).launch {
            val maxDistance = PreferenceStorage.getPropertyInt(HealthGridApplication.getApplicationContext(), PreferenceStorage.MAX_EXPOSURE_DISTANCE_METERS)
            if(maxDistance > 0) {
                curMaxExposureDistance = maxDistance
            }
            infectedCoordinates.data?.date?.let { date ->
                val userLocationPoints: List<LocationInfoEntity>? =
                    LocationInfoProvider.instance?.getDataByDate(date)
                if (userLocationPoints != null) {
                    infectedCoordinates.data?.points?.forEach { point ->
                        userLocationPoints.forEach { userLocation ->
                            point.latitude?.let { lat ->
                                point.longitude?.let { lng ->
                                    checkPointForExposure(
                                        createLocationObject(lat, lng),
                                        createLocationObject(userLocation.latitude, userLocation.longitude)
                                    )
                                }
                            }
                        }
                    }
                }
            }
            callback((infectedCoordinates.data?.date ?: "") to exposureCount)
        }
    }

    private fun createLocationObject(lat: String, long: String): Location? {
        var location: Location? = null
        try {
            location = Location("")
            location.latitude = lat.toDouble()
            location.longitude = long.toDouble()
        } catch (e: Exception) {
        }
        return location
    }

    private fun checkPointForExposure(user: Location?, other: Location?) {
        if(user != null && other != null) {
            val distanceMeter = user.distanceTo(other)
            if(distanceMeter <= curMaxExposureDistance)
                ++exposureCount
        }
    }
}