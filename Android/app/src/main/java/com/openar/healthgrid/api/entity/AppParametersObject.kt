package com.openar.healthgrid.api.entity

import com.google.gson.annotations.SerializedName

data class AppParametersObject (
    @SerializedName("result")
    var data: AppParametersData? = null
)

data class AppParametersData (

    @SerializedName("minColor")
    var minColor: String? = null,

    @SerializedName("maxColor")
    var maxColor: String? = null,

    @SerializedName("exposureDistance")
    var exposureDistance: Int? = null
)