package com.openar.healthgrid.api.entity

import com.google.gson.annotations.SerializedName

data class LatLng (
    @SerializedName("Latitude")
    var latitude: String? = null,

    @SerializedName("Longitude")
    var longitude: String? = null
)