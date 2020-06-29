package com.openar.healthgrid.api.approov

import com.openar.healthgrid.HealthGridApplication
import hu.akarnokd.rxjava3.retrofit.RxJava3CallAdapterFactory
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object ApproovServiceBuilder {
//    const val BASE_URL = "http://192.168.15.30:8080/"
    const val BASE_URL = "https://swaggerui.healthgridalliance.org/"

    @JvmStatic
    val retrofitInstance: Retrofit
        get() {
            val retrofitBuilder = Retrofit.Builder()
                .baseUrl(BASE_URL)
                .addConverterFactory(GsonConverterFactory.create())
                .addCallAdapterFactory(RxJava3CallAdapterFactory.create())
            return HealthGridApplication.approovService.getRetrofit(retrofitBuilder)
        }
}