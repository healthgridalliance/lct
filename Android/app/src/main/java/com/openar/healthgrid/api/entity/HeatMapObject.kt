package com.openar.healthgrid.api.entity

import com.google.gson.annotations.SerializedName

data class HeatMapObject (
    @SerializedName("Date")
    var date: String? = null,

    @SerializedName("MinColor")
    var minColor: String? = null,

    @SerializedName("MaxColor")
    var maxColor: String? = null,

    @SerializedName("LatLng")
    var points: List<LatLng>? = null
)