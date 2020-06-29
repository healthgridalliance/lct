package com.openar.healthgrid.ui.activity.map

import android.Manifest
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.ImageButton
import androidx.core.view.forEach
import androidx.lifecycle.Observer
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.openar.healthgrid.Constants
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.exposure.ExposureActivity
import com.openar.healthgrid.ui.activity.map.dialog.bottomsheet.ConfigurationBottomSheetDialog
import com.openar.healthgrid.ui.activity.map.dialog.OpenAppSettingsDialog
import com.openar.healthgrid.ui.activity.map.dialog.infected.ConfirmInfectedStatusDialog
import com.openar.healthgrid.util.OfflineNotificationUtils
import com.openar.healthgrid.util.PermissionUtils
import com.openar.healthgrid.util.PreferenceStorage
import kotlinx.android.synthetic.main.no_connection_alert.*


abstract class BottomSheetActivity : BaseLoadActivity(), OnMapReadyCallback {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val bottomNavigationView = findViewById<View>(R.id.bottom_navigation) as BottomNavigationView
        bottomNavigationView.menu.forEach {
            bottomNavigationView.findViewById<View>(it.itemId).setOnLongClickListener { true }
        }
        bottomNavigationView.setOnNavigationItemSelectedListener { item ->
            when (item.itemId) {
                R.id.my_status -> {
                    val bottomSheet = ConfirmInfectedStatusDialog.newInstance()
                    bottomSheet.show(supportFragmentManager, ConfirmInfectedStatusDialog.CONFIRM_STATUS_TAG)
                    OfflineNotificationUtils.removeSnackBarMessage(top_coordinator, this)
                    mapsViewModel.setBottomSheetOpenedStatus(true)
                }
                R.id.configuration -> {
                    mapsViewModel.loadTrackingStatusValue(this)
                    val bottomSheet = ConfigurationBottomSheetDialog.newInstance()
                    bottomSheet.show(supportFragmentManager, ConfigurationBottomSheetDialog.BOTTOM_SHEET_TAG)
                    OfflineNotificationUtils.removeSnackBarMessage(top_coordinator, this)
                    mapsViewModel.setBottomSheetOpenedStatus(true)
                }
                R.id.check_exposure -> onCheckExposureTap()
            }
            true
        }

        val checkExposure = findViewById<ImageButton>(R.id.check_exposure_image)
            checkExposure.setOnClickListener {
            onCheckExposureTap()
        }
    }

    private fun onCheckExposureTap() {
        if(OfflineNotificationUtils.verifyAvailableNetwork(this)) {
            val hasPermission = PermissionUtils.isPermissionGranted(this, Manifest.permission.ACCESS_FINE_LOCATION)
            if(!hasPermission) {
                if(!PreferenceStorage.getPropertyBooleanFalse(this, PreferenceStorage.SETTINGS_DIALOG_VISIBLE)) {
                    OpenAppSettingsDialog.newInstance().show(supportFragmentManager, OpenAppSettingsDialog.DIALOG_TAG)
                    PreferenceStorage.addPropertyBoolean(this, PreferenceStorage.SETTINGS_DIALOG_VISIBLE, true)
                }
            }
            PermissionUtils.checkGeolocationServicesSwitchedOn(this, {res ->
                if(res && hasPermission) {
                    heatZonesViewModel.onExposureCheckTap()
                    heatZonesViewModel.getRequestCount().observe(this, Observer { requestCount ->
                        if(requestCount == Constants.DAYS_BEFORE_TODAY) {
                            val intent = Intent(this, ExposureActivity::class.java)
                            intent.putExtra(ExposureActivity.FULL_ACTIVITY, false)
                            startActivity(intent)
                        }
                    })
                }
            })
        }
        else
            OfflineNotificationUtils.showSnackBarMessage(top_coordinator, this)
    }

    override fun onDestroy() {
        permissionsViewModel.settingsOpened = false
        super.onDestroy()
    }
}