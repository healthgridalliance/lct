package com.openar.healthgrid.ui.activity.map.viewmodel

import android.location.Location
import com.openar.healthgrid.api.entity.HeatMapObject
import com.openar.healthgrid.database.LocationInfoEntity

interface ApiContract {

    interface ViewModel {
        fun onError(error: String)
        fun onAppRegistered()
        fun onSuccessfulRequest(msg: String?)
        fun onHeatZonesUpdated(heatZones: HeatMapObject?)
        fun onLocalHeatZonesUpdated(infectedLocations: HeatMapObject?)
    }

    interface Repository {
        fun registerApp()
        fun changeInfectedStatus(infected: Boolean)
        fun deleteAllData()
        fun sendLocation(location: LocationInfoEntity)
        fun sendLocationList(locationList: List<LocationInfoEntity>)
        fun getHeatZones()
        fun getLocalHeatZones(latLng: Location?, date: String)
    }
}