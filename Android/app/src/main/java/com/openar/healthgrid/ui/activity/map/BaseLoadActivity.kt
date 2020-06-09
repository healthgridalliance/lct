package com.openar.healthgrid.ui.activity.map

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.ImageButton
import com.google.android.gms.maps.LocationSource
import com.google.android.gms.maps.OnMapReadyCallback
import com.openar.healthgrid.Constants
import com.openar.healthgrid.ui.activity.map.controller.MapController
import com.openar.healthgrid.ui.activity.map.dialog.ConfigurationBottomSheetDialog
import com.openar.healthgrid.ui.activity.map.dialog.LegendInfoDialog
import com.openar.healthgrid.ui.activity.welcome.WelcomeActivity
import com.openar.healthgrid.util.*
import kotlinx.android.synthetic.main.no_connection_alert.*

abstract class BaseLoadActivity : NetworkActivity(), OnMapReadyCallback, LocationSource.OnLocationChangedListener {
    protected var isWelcomeVisible: Boolean = false
    private var infoDialog: LegendInfoDialog? = null
    private lateinit var infoButton: ImageButton
    protected var mapController: MapController? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        showWelcomeScreenIfNeeded()
        prepareTestData()
    }

    override fun onStart() {
        super.onStart()
        if(!isWelcomeVisible && mapsViewModel.isBottomSheetOpened().value == false)
            PermissionUtils.checkLocationPermission(this)
        WorkUtils.startBackgroundJob(this)
    }

    private fun showWelcomeScreenIfNeeded() {
        if (PreferenceStorage.getPropertyBooleanTrue(applicationContext, PreferenceStorage.FIRST_LAUNCH)) {
            startActivity(Intent(this, WelcomeActivity::class.java))
            isWelcomeVisible = true
        }
    }

    private fun prepareTestData() {
        mapsViewModel.initApp()
    }

    override fun onRestart() {
        super.onRestart()
        if (isWelcomeVisible) {
            if (!OfflineNotificationUtils.verifyAvailableNetwork(this)) {
                OfflineNotificationUtils.showSnackBarMessage(top_coordinator, this)
            }
            if(mapsViewModel.isBottomSheetOpened().value == false)
                PermissionUtils.checkLocationPermission(this)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        isWelcomeVisible = false
        when (requestCode) {
            MapsMainActivity.LOCATION_PERMISSION_REQUEST_CODE -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    mapsViewModel.setTrackingStatusId(Constants.ACTIVE_TRACKING_STATUS)
                    WorkUtils.startBackgroundJob(this)
                    mapController?.enableUserLocation(this)
                }
            }
        }
        return
    }

    override fun onDestroy() {
        PreferenceStorage.addPropertyBoolean(this, PreferenceStorage.TRACKING_STARTED_FLAG, false)
        BroadcastUtils.sendBroadcast(this, ConfigurationBottomSheetDialog.STOP_LOCATION)
        super.onDestroy()
    }
}