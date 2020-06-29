package com.openar.healthgrid.api.approov.retrofit

import com.google.gson.annotations.SerializedName

data class LoggableToken(
    @SerializedName("did")
    var deviceId: String? = null,

    @SerializedName("exp")
    var expireTime: String? = null
)