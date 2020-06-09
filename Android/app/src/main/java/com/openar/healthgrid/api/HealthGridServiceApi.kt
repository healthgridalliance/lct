package com.openar.healthgrid.api

import com.openar.healthgrid.api.entity.HeatMapObject
import com.openar.healthgrid.api.entity.ResultList
import com.openar.healthgrid.api.entity.ServerMessage
import com.openar.healthgrid.database.LocationInfoEntity
import io.reactivex.rxjava3.core.Single
import retrofit2.http.*

interface HealthGridServiceApi {

    @POST(REGISTRATION)
    fun registerAppWithApproov(
    ): Single<ResultList>

    @POST(STATUS_CHANGING)
    fun changeInfectedStatus(
        @Query("Infected") infected: Boolean
    ): Single<ServerMessage>

    @DELETE(DATA_DELETION)
    @Headers("Content-Type: application/json")
    fun deleteAllData(
    ): Single<ServerMessage>

    @POST(LOCATION_HISTORY)
    @Headers("Content-Type: application/json")
    fun sendLocation(
        @Body location: LocationInfoEntity
    ): Single<ServerMessage>

    // TODO change api path when it will be
    @POST(LOCATION_HISTORY_LIST)
    @Headers("Content-Type: application/json")
    fun sendLocationList(
        @Body locationList: List<LocationInfoEntity>
    ): Single<ServerMessage>

    @GET(HEAT_ZONES_GET)
    fun getHeatZones(): Single<HeatMapObject>

    @POST(HEAT_ZONES)
    fun getLocalHeatZones(
        @Query("Latitude") lat: String,
        @Query("Longitude") lang: String,
        @Query("Date") date: String
    ): Single<HeatMapObject>

    companion object {
        const val REGISTRATION = "api/COVID19App"
        const val STATUS_CHANGING = "api/COVID19Status"
        const val DATA_DELETION = "api/LocationHistory/"
        const val LOCATION_HISTORY = "api/LocationHistory/"
        const val LOCATION_HISTORY_LIST = "api/LocationHistory"
        const val HEAT_ZONES_GET = "api/HeatZones/Get"
        const val HEAT_ZONES = "api/HeatZones"
    }
}