package com.openar.healthgrid.api

import android.util.Log
import com.openar.healthgrid.api.approov.ApproovServiceBuilder.retrofitInstance
import com.openar.healthgrid.api.entity.HeatMapObject
import com.openar.healthgrid.api.entity.ResultList
import com.openar.healthgrid.api.entity.ServerMessage
import com.openar.healthgrid.database.LocationInfoEntity
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


    fun getAppId(): Single<ResultList> {
        Log.d(TAG, "POST api/COVID19App REQUEST")
        return api.registerAppWithApproov()
    }

    fun changeInfectedStatus(infected: Boolean): Single<ServerMessage> {
        Log.d(TAG, "POST api/COVID19Status REQUEST")
        return api.changeInfectedStatus(infected)
    }

    fun deleteAllData(): Single<ServerMessage> {
        Log.d(TAG, "DELETE api/LocationHistory/ REQUEST")
        return api.deleteAllData()
    }

    fun sendLocation(location: LocationInfoEntity): Single<ServerMessage> {
        Log.d(TAG, "POST api/LocationHistory/ REQUEST")
        return api.sendLocation(location)
    }

    fun sendLocationList(locationList: List<LocationInfoEntity>): Single<ServerMessage> {
        Log.d(TAG, "POST api/LocationHistory REQUEST")
        return api.sendLocationList(locationList)
    }

    fun getHeatZones(): Single<HeatMapObject> {
        Log.d(TAG, "GET api/HeatZones/Get REQUEST")
        return api.getHeatZones()
    }

    fun getLocalHeatZones(lat: String, lang: String, date: String): Single<HeatMapObject> {
        Log.d(TAG, "POST api/HeatZones REQUEST")
        return api.getLocalHeatZones(lat, lang, date)
    }
}