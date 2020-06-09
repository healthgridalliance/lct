package com.openar.healthgrid.ui.activity.map.controller

import android.app.Activity
import android.graphics.Color
import android.location.Location
import android.location.LocationManager
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.TileOverlay
import com.google.android.gms.maps.model.TileOverlayOptions
import com.google.maps.android.heatmaps.Gradient
import com.google.maps.android.heatmaps.HeatmapTileProvider
import com.openar.healthgrid.ui.activity.map.viewmodel.MapsViewModel
import com.openar.healthgrid.util.PermissionUtils
import kotlin.math.pow
import kotlin.math.roundToInt

class MapController(private val mapsViewModel: MapsViewModel) {
    private var mOverlay: TileOverlay? = null
    private lateinit var mProvider: HeatmapTileProvider
    private var curZoom = DEFAULT_ZOOM
    private var mMap: GoogleMap? = null
    private var fusedLocationClient: FusedLocationProviderClient? = null

    fun configureMap(googleMap: GoogleMap, activity: Activity, isWelcomeVisible: Boolean) {
        mMap = googleMap
        setMapListeners()
        drawHeatMap()
        if (!isWelcomeVisible) {
            enableUserLocation(activity)
        }
    }

    fun enableUserLocation(activity: Activity) {
        if(PermissionUtils.checkLocationPermission(activity)) {
            mMap?.isMyLocationEnabled = true
            mMap?.uiSettings?.isMyLocationButtonEnabled = false
            mMap?.uiSettings?.isCompassEnabled = false
            fusedLocationClient = LocationServices.getFusedLocationProviderClient(activity)
            setUpListeners()
        }
    }

    private fun setUpListeners() {
        fusedLocationClient?.lastLocation?.addOnSuccessListener { location: Location? ->
            location?.let {
                if (mapsViewModel.getLastKnownLocation().value == null) {
//                    animateMapCamera(it)
                }
                mapsViewModel.setLastKnownLocation(it)
            }
        }
    }

    fun animateMapCamera(location: Location, zoom: Float = 15f) {
        mMap?.animateCamera(
            CameraUpdateFactory.newLatLngZoom(LatLng(location.latitude, location.longitude), zoom)
        )
    }

    fun drawHeatMap(pos: Int = 0) {
        mOverlay?.remove()
        val colors = intArrayOf(
            Color.rgb(102, 225, 0),  // green
            Color.rgb(255, 0, 0) // red
        )
        val startPoints = floatArrayOf(0.1f, 1f)
        val gradient = Gradient(colors, startPoints)
        mProvider = HeatmapTileProvider.Builder()
            .data(mapsViewModel.getHeatMapList(pos))
            .gradient(gradient)
            .opacity(0.7)
            .radius(getMapProviderRadius())
            .maxIntensity(getMapIntensity())
            .build()
        mOverlay = mMap?.addTileOverlay(TileOverlayOptions().tileProvider(mProvider))
        mOverlay?.clearTileCache()
        val targetLocation = Location(LocationManager.GPS_PROVIDER)
        targetLocation.latitude = 37.612003
        targetLocation.longitude = -122.382923
        animateMapCamera(targetLocation, DEFAULT_ZOOM)
    }

    private fun setMapListeners() {
        mMap?.setOnCameraIdleListener {
            mMap?.let { map ->
                map.cameraPosition?.let {
                    if (curZoom != it.zoom) {
                        curZoom = it.zoom
                        mProvider.apply {
                            setRadius(getMapProviderRadius(it.zoom))
                            setMaxIntensity(getMapIntensity(it.zoom))
                        }
                        mOverlay?.remove()
                        mOverlay = mMap?.addTileOverlay(TileOverlayOptions().tileProvider(mProvider))
                    }
                }
            }
        }
    }

    private fun getMapIntensity(zoom: Float = DEFAULT_ZOOM): Double {
        if (zoom > 12.0) return 12.0
        return 800.0 / (1.2).pow(zoom.toDouble())
    }

    private fun getMapProviderRadius(zoom: Float = DEFAULT_ZOOM): Int = (1.5 * zoom).roundToInt()

    companion object {
        const val MAP_INTENSITY = 50.0
        const val DEFAULT_ZOOM = 10f
    }
}