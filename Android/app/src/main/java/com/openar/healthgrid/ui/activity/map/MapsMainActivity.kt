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

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val mapFragment = supportFragmentManager.findFragmentById(R.id.map) as SupportMapFragment
        mapFragment.getMapAsync(this)
        mapController = MapController(mapsViewModel, heatZonesViewModel)
    }

    override fun onStart() {
        super.onStart()
        heatZonesViewModel.updateTodayHeatZones()
        mapController?.enableUserLocation(this)
        my_location.setOnClickListener {
            mapsViewModel.getLastKnownLocation().value?.let { location ->
                mapController?.animateMapCamera(location)
            }
        }

    }

    override fun onMapReady(googleMap: GoogleMap) {
        mapController?.configureMap(googleMap, this, isWelcomeVisible)
    }

    override fun onLocationChanged(location: Location) {
        mapsViewModel.setLastKnownLocation(location)
        mapController?.animateMapCamera(location)
    }

    override fun onStop() {
        mapController?.stopLocationUpdates()
        super.onStop()
    }

    companion object {
        const val LOCATION_PERMISSION_REQUEST_CODE = 12
        const val BACKGROUND_LOCATION_PERMISSION_REQUEST_CODE = 13
    }
}
