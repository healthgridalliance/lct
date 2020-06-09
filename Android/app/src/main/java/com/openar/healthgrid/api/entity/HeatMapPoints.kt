package com.openar.healthgrid.api.entity

import com.google.android.gms.maps.model.LatLng

data class HeatMapPoints(
    var points: MutableList<LatLng> = mutableListOf()
)