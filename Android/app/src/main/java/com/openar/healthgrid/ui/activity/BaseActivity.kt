package com.openar.healthgrid.ui.activity

import android.os.Bundle
import android.view.WindowManager
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import com.openar.healthgrid.Constants
import com.openar.healthgrid.R
import com.openar.healthgrid.service.BackgroundLocationWork
import com.openar.healthgrid.ui.activity.map.viewmodel.MapsViewModel
import com.openar.healthgrid.util.PreferenceStorage
import com.openar.healthgrid.util.WorkUtils

abstract class BaseActivity : AppCompatActivity() {
    protected val mapsViewModel: MapsViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.AppTheme_base)
        super.onCreate(savedInstanceState)
        WorkUtils.configureCheckExpiredDataJob(this)
    }

    private fun setTransparentStatusBar() {
        window.setFlags(
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        )
    }

    override fun onStart() {
        super.onStart()
        val trackingStatus = PreferenceStorage.getPropertyInt(this, PreferenceStorage.TRACKING_STATUS_VALUE)
        if(trackingStatus == Constants.ACTIVE_TRACKING_STATUS) {
            WorkUtils.stopUniqueJob(this, BackgroundLocationWork.JOB_ID)
        }
    }

    override fun onStop() {
        super.onStop()
        val trackingStatus = PreferenceStorage.getPropertyInt(this, PreferenceStorage.TRACKING_STATUS_VALUE)
        if(trackingStatus == Constants.ACTIVE_TRACKING_STATUS) {
            WorkUtils.startBackgroundJob(this)
        }
    }
}