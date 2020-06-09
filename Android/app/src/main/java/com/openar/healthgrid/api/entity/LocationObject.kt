package com.openar.healthgrid.api.entity

import com.google.gson.annotations.SerializedName

data class LocationObject(
    @SerializedName("id")
    var id: Int? = null,

    @SerializedName("applicationId")
    var applicationId: String? = null,

    @SerializedName("checkInTime")
    var checkInTime: String? = null,

    @SerializedName("checkOutTime")
    var checkOutTime: String? = null,

    @SerializedName("date")
    var date: String? = null,

    @SerializedName("latitude")
    var latitude: String? = null,

    @SerializedName("longitude")
    var longitude: String? = null
)