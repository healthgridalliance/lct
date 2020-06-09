package com.openar.healthgrid.api.entity

import com.google.gson.annotations.SerializedName

data class ServerMessage (
    @SerializedName("message")
    var message: String? = null
    )