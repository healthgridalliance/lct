package com.openar.healthgrid.api

import android.util.Log
import com.openar.healthgrid.api.approov.ApproovServiceBuilder.retrofitInstance
import com.openar.healthgrid.api.entity.*
import io.reactivex.rxjava3.core.Single
import retrofit2.create

class HealthGridService private constructor(){

    private object HOLDER {
        val INSTANCE = HealthGridService()
    }
    companion object {
        val instance: HealthGridService by lazy { HOLDER.INSTANCE }
        private var api: HealthGridServiceApi = retrofitInstance.create()
        const val TAG = "ApiRequest"
    }

    fun deleteAllData(testId: String): Single<ServerMessage> {
        Log.d(TAG, "DELETE api/LocationHistory/ REQUEST")
        return api.deleteAllData(testId)
    }

    fun sendLocationList(locationList: List<LocationInfoObject>): Single<ServerMessage> {
        Log.d(TAG, "POST api/LocationHistory REQUEST")
        return api.sendLocationList(locationList)
    }

    fun getHeatZones(lat: String, lang: String, date: String): Single<HeatMapObject> {
        Log.d(TAG, "GET api/HeatZones/Get REQUEST")
        return api.getHeatZones(lat, lang, date)
    }

    fun getInitialAppParameters(): Single<AppParametersObject> {
        Log.d(TAG, "GET api/AppSetting/Get REQUEST")
        return api.getInitialAppParameters()
    }
}