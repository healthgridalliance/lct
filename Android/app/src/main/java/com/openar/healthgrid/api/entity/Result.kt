package com.openar.healthgrid.api.entity

import com.google.gson.annotations.SerializedName

data class ResultList(
    @SerializedName("result")
    var result: List<Test>? = null,

    @SerializedName("message")
    var message: String? = null
)

data class Test(
    @SerializedName("id")
    var id: Int? = null,

    @SerializedName("keyId")
    var keyId: String? = null,

    @SerializedName("name")
    var name: String? = null,

    @SerializedName("status")
    var status: Int? = null,

    @SerializedName("createdDate")
    var createdDate: String? = null,

    @SerializedName("modifiedDate")
    var modifiedDate: String? = null,

    @SerializedName("isActive")
    var isActive: Boolean? = null,

    @SerializedName("syncingDate")
    var syncingDate: String? = null
)