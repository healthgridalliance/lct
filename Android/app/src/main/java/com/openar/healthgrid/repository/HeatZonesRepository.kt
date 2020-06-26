package com.openar.healthgrid.repository

import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationResult
import com.openar.healthgrid.Constants
import com.openar.healthgrid.HealthGridApplication
import com.openar.healthgrid.api.entity.HeatMapObject
import com.openar.healthgrid.api.entity.CustomLatLng
import com.openar.healthgrid.service.SaveLocationDataService
import com.openar.healthgrid.util.DateUtils
import com.openar.healthgrid.util.UpdateLocationUtils

class HeatZonesRepository private constructor() {
    var exposureInfo: MutableMap<String, Int>? = null
        get() = field

    var heatZonesList: MutableMap<String, List<CustomLatLng>> = mutableMapOf()
        get() = field

    private object HOLDER {
        val INSTANCE = HeatZonesRepository()
    }

    companion object {
        val instance: HeatZonesRepository by lazy { HOLDER.INSTANCE }
    }

    private val location = UpdateLocationUtils()

    fun getLastKnownLocationAndCheckExposure(apiRequestsRepository: ApiRequestsRepository?, noLocationCallback: () -> Unit, needCheckExposure: Boolean) {
        exposureInfo = mutableMapOf()
        val locationCallback: LocationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult?) {
                if (locationResult != null) {
                    SaveLocationDataService.instance.saveLocationIfNeeded(locationResult.locations)
                    configureRequests(apiRequestsRepository, locationResult, needCheckExposure)
                } else {
                    noLocationCallback()
                }
            }
        }
        location.getCurrentLocation(HealthGridApplication.getApplicationContext(), locationCallback)
    }

    fun getHeatZones(apiRequestsRepository: ApiRequestsRepository?, noLocationCallback: () -> Unit, daysBefore: Int = 0) {
        val locationCallback: LocationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult?) {
                if (locationResult != null) {
                    SaveLocationDataService.instance.saveLocationIfNeeded(locationResult.locations)
                    sendRequest(apiRequestsRepository, locationResult, daysBefore, false)
                } else {
                    noLocationCallback()
                }
            }
        }
        location.getCurrentLocation(HealthGridApplication.getApplicationContext(), locationCallback)
    }

    fun saveExposureResult(info: Pair<String, Int>) {
        exposureInfo?.put(info.first, info.second)
    }

    fun resetData() {
        exposureInfo = null
        heatZonesList = mutableMapOf()
    }

    private fun configureRequests(apiRequestsRepository: ApiRequestsRepository?, locationResult: LocationResult, needCheckExposure: Boolean) {
        for (daysBefore in 1..Constants.DAYS_BEFORE_TODAY) {
            sendRequest(apiRequestsRepository, locationResult, daysBefore - 1, needCheckExposure)
        }
    }

    private fun sendRequest(
        apiRequestsRepository: ApiRequestsRepository?,
        locationResult: LocationResult,
        daysBefore: Int,
        needCheckExposure: Boolean
    ) {
        apiRequestsRepository?.getHeatZones(
            locationResult.lastLocation,
            DateUtils.getDateDaysBefore(daysBefore),
            needCheckExposure
        )
    }

    fun saveHeatZones(infectedLocations: HeatMapObject) {
        infectedLocations.data?.let {
            it.date?.let { date -> it.points?.let { zones -> heatZonesList.put(date, zones) } }
        }
    }
}