package com.openar.healthgrid.ui.activity.map

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.activity.viewModels
import androidx.lifecycle.Observer
import com.openar.healthgrid.ui.activity.exposure.HeatZonesViewModel
import com.openar.healthgrid.ui.activity.exposure.PermissionsViewModel
import com.openar.healthgrid.ui.activity.map.dialog.NoGeolocationDialog
import com.openar.healthgrid.ui.activity.map.dialog.OpenAppSettingsDialog
import com.openar.healthgrid.util.PermissionUtils
import com.openar.healthgrid.util.PreferenceStorage

abstract class PermissionsActivity : NetworkActivity() {
    protected val permissionsViewModel: PermissionsViewModel by viewModels()
    protected val heatZonesViewModel: HeatZonesViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if(!permissionsViewModel.isWelcomeVisible()) {
            if(PermissionUtils.isPermissionGranted(this, Manifest.permission.ACCESS_FINE_LOCATION)) {
                permissionsViewModel.setLocationPermissionStatus(true)
            } else {
                showPermissionDialogIfNeeded()
            }
            PermissionUtils.checkGeolocationServicesSwitchedOn(this, this::geolocationSwitchedOn)
        }

        heatZonesViewModel.getNoLocationTrigger().observe(this, Observer { noLocation ->
            if(noLocation) {
                heatZonesViewModel.resetNoLocationTrigger()
                NoGeolocationDialog.newInstance().show(supportFragmentManager, NoGeolocationDialog.DIALOG_TAG)
            }
        })
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
                        mapsViewModel.trackingStatusId.value?.let { mapsViewModel.setTrackingStatusId(it) }
                    }
                }
            }
        }
    }

    private fun geolocationSwitchedOn(res: Boolean) = permissionsViewModel.setLocationSwitchedOnStatus(res)

    private fun showPermissionDialogIfNeeded() {
        if(!PermissionUtils.isPermissionGranted(this, Manifest.permission.ACCESS_FINE_LOCATION)) {
            if(!PreferenceStorage.getPropertyBooleanFalse(this, PreferenceStorage.SETTINGS_DIALOG_VISIBLE)) {
                OpenAppSettingsDialog.newInstance().show(supportFragmentManager, OpenAppSettingsDialog.DIALOG_TAG)
                PreferenceStorage.addPropertyBoolean(this, PreferenceStorage.SETTINGS_DIALOG_VISIBLE, true)
            }
        }
    }
}