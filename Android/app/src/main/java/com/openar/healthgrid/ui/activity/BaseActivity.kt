package com.openar.healthgrid.ui.activity

import android.os.Bundle
import android.os.Handler
import android.view.WindowManager
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.map.viewmodel.MapsViewModel
import com.openar.healthgrid.util.WorkUtils

abstract class BaseActivity : AppCompatActivity() {
    protected val mapsViewModel: MapsViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        // TODO remove in the next build
        Handler().postDelayed({}, 4000)
        setTheme(R.style.AppTheme_base)
        super.onCreate(savedInstanceState)
        setTransparentStatusBar()
        WorkUtils.configureCheckExpiredDataJob(this)
    }

    private fun setTransparentStatusBar() {
        window.setFlags(
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        )
    }


}