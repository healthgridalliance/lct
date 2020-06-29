package com.openar.healthgrid

import android.content.Context
import androidx.multidex.MultiDexApplication
import com.openar.healthgrid.api.approov.retrofit.ApproovService
import com.openar.healthgrid.util.PreferenceStorage

class HealthGridApplication : MultiDexApplication() {

    init {
        instance = this
    }

    override fun onCreate() {
        super.onCreate()
        approovService = ApproovService(applicationContext, resources.getString(R.string.approov_config))
        PreferenceStorage.addPropertyBoolean(this, PreferenceStorage.TRACKING_STARTED_FLAG, false)
    }

    companion object {
        lateinit var approovService: ApproovService
        private lateinit var instance: HealthGridApplication

        fun getApplicationContext(): Context {
            return instance.applicationContext
        }
    }
}