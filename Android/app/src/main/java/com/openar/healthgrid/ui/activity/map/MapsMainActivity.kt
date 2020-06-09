package com.openar.healthgrid.ui.activity.map

import android.location.Location
import android.os.Bundle
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.LocationSource.OnLocationChangedListener
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.SupportMapFragment
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.map.controller.MapController
import kotlinx.android.synthetic.main.map_action_buttons.*


class MapsMainActivity : MapsManageButtonsActivity(), OnMapReadyCallback, OnLocationChangedListener {
    private val mListener: OnLocationChangedListener? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val mapFragment = supportFragmentManager.findFragmentById(R.id.map) as SupportMapFragment
        mapFragment.getMapAsync(this)
    }

    override fun onStart() {
        super.onStart()
        my_location.setOnClickListener {
            mapsViewModel.getLastKnownLocation().value?.let { location ->
                mapController?.animateMapCamera(location)
            }
        }
    }

    override fun onMapReady(googleMap: GoogleMap) {
        mapController = MapController(mapsViewModel)
        mapController?.configureMap(googleMap, this, isWelcomeVisible)
    }

    override fun onLocationChanged(location: Location) {
        if (mListener != null) {
            mListener.onLocationChanged(location)
//            mapController.animateMapCamera(location)
        }
    }

    companion object {
        const val LOCATION_PERMISSION_REQUEST_CODE = 12
        const val BACKGROUND_LOCATION_PERMISSION_REQUEST_CODE = 13
    }
}
