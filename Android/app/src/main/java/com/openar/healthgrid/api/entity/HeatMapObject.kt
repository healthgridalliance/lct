package com.openar.healthgrid.api.entity

import com.google.gson.annotations.SerializedName

data class HeatMapObject (
    @SerializedName("result")
    var data: HeatMapData? = null
)

data class HeatMapData (
    @SerializedName("date")
    var date: String? = null,

    @SerializedName("latLongs")
    var points: List<CustomLatLng>? = null
)