package com.openar.healthgrid.repository

import android.location.Location
import com.openar.healthgrid.Constants
import com.openar.healthgrid.api.entity.HeatMapObject
import com.openar.healthgrid.database.LocationInfoEntity
import com.openar.healthgrid.database.LocationInfoProvider
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class CheckExposureRepository(private val infectedCoordinates: HeatMapObject) {
    private var exposureCount = 0

    fun checkExposure(callback: (pair: Pair<String, Int>) -> Unit) {
        CoroutineScope(Dispatchers.Default).launch {
            infectedCoordinates.date?.let { date ->
                val userLocationPoints: List<LocationInfoEntity>? =
                    LocationInfoProvider.instance?.getDataByDate(date)
                if (userLocationPoints != null) {
                    infectedCoordinates.points?.forEach { point ->
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
                callback(date to exposureCount)
            }
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
            if(distanceMeter <= Constants.MAX_DISTANCE_EXPOSURE_METER)
                ++exposureCount
        }
    }
}