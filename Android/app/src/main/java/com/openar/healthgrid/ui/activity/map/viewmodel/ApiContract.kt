package com.openar.healthgrid.ui.activity.map.viewmodel

import android.location.Location
import com.openar.healthgrid.api.entity.AppParametersObject
import com.openar.healthgrid.api.entity.HeatMapObject
import com.openar.healthgrid.database.LocationInfoEntity

interface ApiContractBase {

    interface ViewModel {
        fun onError(error: String)
        fun onGetSettingsError(error: String)
        fun onAppRegistered()
        fun onSuccessfulRequest(msg: String?)
        fun onGetAppParameters(parameters: AppParametersObject)
    }

    interface Repository {
        fun deleteAllData()
        fun sendLocationList(locationList: List<LocationInfoEntity>, testId: String)
        fun getInitialAppParameters()
    }
}

interface ApiContractHeatZones {

    interface ViewModel {
        fun onError(error: String)
        fun onGetHeatZonesError(error: String)
        fun onHeatZonesUpdated(infectedLocations: HeatMapObject, needCheckExposure: Boolean)
    }

    interface Repository {
        fun getHeatZones(latLng: Location?, date: String, needCheckExposure: Boolean)
    }
}