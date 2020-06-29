package com.openar.healthgrid.api.entity

import com.google.gson.annotations.SerializedName

data class LocationInfoObject(

    @SerializedName("testUniqueId")
    var testUniqueId: String,

    @SerializedName("checkInTime")
    var checkInTime: String,

    @SerializedName("checkOutTime")
    var checkOutTime: String?,

    @SerializedName("date")
    var date: String,

    @SerializedName("latitude")
    var latitude: String,

    @SerializedName("longitude")
    var longitude: String
)