package com.openar.healthgrid.ui.activity.map.controller

import android.Manifest
import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.location.Location
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.Observer
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationResult
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.TileOverlay
import com.google.android.gms.maps.model.TileOverlayOptions
import com.google.maps.android.heatmaps.Gradient
import com.google.maps.android.heatmaps.HeatmapTileProvider
import com.openar.healthgrid.HealthGridApplication
import com.openar.healthgrid.ui.activity.exposure.HeatZonesViewModel
import com.openar.healthgrid.ui.activity.map.viewmodel.MapsViewModel
import com.openar.healthgrid.util.PermissionUtils
import com.openar.healthgrid.util.PreferenceStorage
import com.openar.healthgrid.util.UpdateLocationUtils
import kotlin.math.pow
import kotlin.math.roundToInt

class MapController(private val mapsViewModel: MapsViewModel, private val heatZonesViewModel: HeatZonesViewModel) {
    private var mOverlay: TileOverlay? = null
    private var mProvider: HeatmapTileProvider? = null
    private var curZoom = DEFAULT_ZOOM
    private var mMap: GoogleMap? = null
    private val location = UpdateLocationUtils()

    private val locationCallback: LocationCallback = object : LocationCallback() {
        override fun onLocationResult(locationResult: LocationResult?) {
            if (locationResult != null) {
                mapsViewModel.setLastKnownLocation(locationResult.lastLocation)
                animateMapCamera(locationResult.lastLocation)
            }
        }
    }

    fun configureMap(googleMap: GoogleMap, activity: Activity, isWelcomeVisible: Boolean) {
        mMap = googleMap
        setMapListeners()
        drawHeatMap()
        if (!isWelcomeVisible) {
            enableUserLocation(activity)
        }
        setHeatMapUpdateListener(activity)
    }

    private fun setHeatMapUpdateListener(activity: Activity) {
        heatZonesViewModel.getHeatMapList()
            .observe(activity as LifecycleOwner, Observer {
                drawHeatMap()
            })
    }

    fun enableUserLocation(activity: Activity) {
        if(PermissionUtils.isPermissionGranted(activity, Manifest.permission.ACCESS_FINE_LOCATION)) {
            mMap?.isMyLocationEnabled = true
            mMap?.uiSettings?.isMyLocationButtonEnabled = false
            mMap?.uiSettings?.isCompassEnabled = false
            startLocationUpdates(activity)
        }
    }

    private fun startLocationUpdates(context: Context) {
        location.configureLocationUpdates(context, locationCallback)
    }

    fun animateMapCamera(location: Location, zoom: Float = DEFAULT_ZOOM) {
        mMap?.animateCamera(
            CameraUpdateFactory.newLatLngZoom(LatLng(location.latitude, location.longitude), zoom)
        )
    }

    fun drawHeatMap(pos: Int = 0) {
        mOverlay?.remove()
        mProvider = null
        mMap?.clear()
        val maxColor = PreferenceStorage.getPropertyString(HealthGridApplication.getApplicationContext(), PreferenceStorage.LEGEND_MAX_COLOR)
        val minColor = PreferenceStorage.getPropertyString(HealthGridApplication.getApplicationContext(), PreferenceStorage.LEGEND_MIN_COLOR)
        val colors = intArrayOf(Color.parseColor(minColor), Color.parseColor(maxColor))
        val startPoints = floatArrayOf(0.1f, 1f)
        val gradient = Gradient(colors, startPoints)
        val points = heatZonesViewModel.getHeatMapList(pos)
        if(points.isNotEmpty()) {
            mProvider = HeatmapTileProvider.Builder()
                .data(points)
                .gradient(gradient)
                .opacity(0.7)
                .radius(getMapProviderRadius())
                .maxIntensity(getMapIntensity())
                .build()
            mOverlay = mMap?.addTileOverlay(TileOverlayOptions().tileProvider(mProvider))
            mOverlay?.clearTileCache()
        }
    }

    private fun setMapListeners() {
        mMap?.setOnCameraIdleListener {
            mMap?.let { map ->
                map.cameraPosition?.let {
                    if (curZoom != it.zoom) {
                        curZoom = it.zoom
                        mProvider?.let { provider ->
                            provider.apply {
                                setRadius(getMapProviderRadius(it.zoom))
                                setMaxIntensity(getMapIntensity(it.zoom))
                            }
                            mOverlay?.remove()
                            mOverlay = mMap?.addTileOverlay(TileOverlayOptions().tileProvider(provider))
                        }
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

    fun stopLocationUpdates() {
        location.unregisterProvider(locationCallback)
    }

    companion object {
        const val MAP_INTENSITY = 50.0
        const val DEFAULT_ZOOM = 18f
    }
}