package com.openar.healthgrid.api.entity

import com.google.gson.annotations.SerializedName

data class CustomLatLng (
    @SerializedName("latitude")
    var latitude: String? = null,

    @SerializedName("longitude")
    var longitude: String? = null
)