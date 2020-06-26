package com.openar.healthgrid.ui.activity.map

import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.ImageButton
import androidx.lifecycle.Observer
import com.google.android.gms.maps.LocationSource
import com.google.android.gms.maps.OnMapReadyCallback
import com.openar.healthgrid.Constants
import com.openar.healthgrid.ui.activity.map.controller.MapController
import com.openar.healthgrid.ui.activity.map.dialog.bottomsheet.ConfigurationBottomSheetDialog
import com.openar.healthgrid.ui.activity.map.dialog.LegendInfoDialog
import com.openar.healthgrid.util.BroadcastUtils
import com.openar.healthgrid.util.PreferenceStorage
import com.openar.healthgrid.util.WorkUtils

abstract class BaseLoadActivity : PermissionsActivity(), OnMapReadyCallback, LocationSource.OnLocationChangedListener {
    protected var isWelcomeVisible: Boolean = false
    private var infoDialog: LegendInfoDialog? = null
    private lateinit var infoButton: ImageButton
    protected var mapController: MapController? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mapsViewModel.loadTrackingStatusValue(this)

        permissionsViewModel.isLocationSwitchedOn().observe(this, Observer { switchedOn ->
            if(switchedOn) {
                mapController?.enableUserLocation(this)
            }
        })
    }

    override fun onStart() {
        super.onStart()
        WorkUtils.startLocationTracking(this)
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
                    WorkUtils.startLocationTracking(this)
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