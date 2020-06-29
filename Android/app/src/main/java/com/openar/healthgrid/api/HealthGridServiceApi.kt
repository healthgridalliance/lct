package com.openar.healthgrid.api

import com.openar.healthgrid.api.entity.*
import io.reactivex.rxjava3.core.Single
import retrofit2.http.*

interface HealthGridServiceApi {

    @DELETE("api/LocationHistory/{$TEST_UNIQUE_ID}")
    fun deleteAllData(@Path(TEST_UNIQUE_ID) uniqueId: String): Single<ServerMessage>

    @POST(LOCATION_HISTORY_LIST)
    @Headers("Content-Type: application/json")
    fun sendLocationList(
        @Body locationList: List<LocationInfoObject>
    ): Single<ServerMessage>

    @GET(HEAT_ZONES_GET)
    @Headers("Content-Type: application/json")
    fun getHeatZones(
        @Query("Latitude") lat: String,
        @Query("Longitude") lang: String,
        @Query("Date") date: String
    ): Single<HeatMapObject>

    @GET(INITIAL_PARAMETERS_GET)
    @Headers("Content-Type: application/json")
    fun getInitialAppParameters(): Single<AppParametersObject>

    companion object {
        const val LOCATION_HISTORY_LIST = "api/LocationHistory"
        const val HEAT_ZONES_GET = "api/HeatZones/Get"
        const val INITIAL_PARAMETERS_GET = "api/AppSetting/Get"

        const val TEST_UNIQUE_ID = "testUniqueId"
    }
}