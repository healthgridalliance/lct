package com.openar.healthgrid.ui.activity.exposure

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.activity.viewModels
import androidx.lifecycle.Observer
import com.openar.healthgrid.Constants
import com.openar.healthgrid.R
import com.openar.healthgrid.repository.HeatZonesRepository
import com.openar.healthgrid.ui.activity.map.MapsMainActivity
import com.openar.healthgrid.ui.activity.map.NetworkActivity
import com.openar.healthgrid.ui.activity.map.dialog.NoGeolocationDialog
import com.openar.healthgrid.ui.activity.welcome.WelcomeActivity
import com.openar.healthgrid.ui.fragment.exposure.ExposureDetailsFragment
import com.openar.healthgrid.ui.fragment.exposure.ExposureResultFragment
import com.openar.healthgrid.ui.fragment.exposure.ExposureStartFragment
import com.openar.healthgrid.util.PermissionUtils
import com.openar.healthgrid.util.PreferenceStorage
import com.openar.healthgrid.util.WorkUtils

class ExposureActivity : NetworkActivity(), ExposureStartFragment.ExposureStartFragmentAction,
    ExposureResultFragment.ExposureResultFragmentAction,
    ExposureDetailsFragment.ExposureDetailsFragmentAction {
    private var isFullActivity = true
    private val permissionsViewModel: PermissionsViewModel by viewModels()
    private val heatZonesViewModel: HeatZonesViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        showWelcomeScreenIfNeeded()
        super.onCreate(savedInstanceState)
        isFullActivity = intent.getBooleanExtra(FULL_ACTIVITY, true)
        if(isFullActivity) {
            mapsViewModel.initApplication()
            goToStartFragment()
        } else {
            goToResultFragment()
        }
        setContentView(R.layout.activity_exposure)
        setUpObservers()
    }

    private fun setUpObservers() {
        heatZonesViewModel.getNoLocationTrigger().observe(this, Observer { noLocation ->
            if (noLocation) {
                heatZonesViewModel.resetNoLocationTrigger()
                NoGeolocationDialog.newInstance()
                    .show(supportFragmentManager, NoGeolocationDialog.DIALOG_TAG)
            }
        })
    }

    override fun onStart() {
        super.onStart()
        WorkUtils.startLocationTracking(this)
    }

    override fun onRestart() {
        super.onRestart()
        permissionsViewModel.setWelcomeVisibleStatus(false)
    }

    override fun needMoreInfo() {
        supportFragmentManager.beginTransaction()
            .replace(
                R.id.exposure_fragment,
                ExposureDetailsFragment.newInstance(),
                ExposureDetailsFragment.EXPOSURE_DETAILS_TAG
            )
            .commit()
    }

    override fun onBackPressed() {
         var curFragment = supportFragmentManager.findFragmentByTag(ExposureDetailsFragment.EXPOSURE_DETAILS_TAG)
         if(curFragment != null && curFragment.isVisible) {
             goToResultFragment()
         } else {
             curFragment = supportFragmentManager.findFragmentByTag(ExposureResultFragment.EXPOSURE_RESULT_TAG)
             if(curFragment != null && curFragment.isVisible) {
                 if(isFullActivity) {
                     goToStartFragment()
                 } else {
                     super.onBackPressed()
                 }
             } else {
                 super.onBackPressed()
             }
         }
    }

    override fun skipCheckExposure() = startMapActivity()
    override fun navigateToMap() = startMapActivity()
    override fun backToResult() = goToResultFragment()

    private fun goToStartFragment() {
        supportFragmentManager.beginTransaction()
            .replace(
                R.id.exposure_fragment,
                ExposureStartFragment.newInstance(),
                ExposureStartFragment.EXPOSURE_START_TAG
            )
            .commit()
    }

    private fun goToResultFragment() {
        supportFragmentManager.beginTransaction()
            .replace(
                R.id.exposure_fragment,
                ExposureResultFragment.newInstance(),
                ExposureResultFragment.EXPOSURE_RESULT_TAG
            )
            .commit()
    }

    override fun checkExposure() {
        heatZonesViewModel.onExposureCheckTap()
        heatZonesViewModel.getRequestCount().observe(this, Observer { requestCount ->
            if(requestCount == Constants.DAYS_BEFORE_TODAY) {
                goToResultFragment()
            }
        })
    }

    private fun showWelcomeScreenIfNeeded() {
        if (PreferenceStorage.getPropertyBooleanTrue(applicationContext, PreferenceStorage.FIRST_LAUNCH)) {
            permissionsViewModel.setWelcomeVisibleStatus(true)
            startActivity(Intent(this, WelcomeActivity::class.java))
            finish()
        }
    }

    private fun startMapActivity() {
        HeatZonesRepository.instance.resetData()
        val intent = Intent(this, MapsMainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
        finish()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when(requestCode) {
            PermissionUtils.REQUEST_CHECK_SETTINGS -> {
                PreferenceStorage.addPropertyBoolean(this, PreferenceStorage.GEOLOCATION_DIALOG_VISIBLE, false)
                when(resultCode) {
                    Activity.RESULT_OK -> {
                        permissionsViewModel.setLocationSwitchedOnStatus(true)
                    }
                    Activity.RESULT_CANCELED -> {
                        permissionsViewModel.setLocationSwitchedOnStatus(false)
                    }
                }
            }
        }
    }

    companion object {
        const val FULL_ACTIVITY = "FULL_ACTIVITY"
    }
}
