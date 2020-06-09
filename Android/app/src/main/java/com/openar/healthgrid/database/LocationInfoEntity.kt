package com.openar.healthgrid.database

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import com.google.gson.annotations.SerializedName

@Entity
class LocationInfoEntity(

    @SerializedName("checkInTime")
    @ColumnInfo(name = "CheckInTime")
    var checkInTime: String,

    @SerializedName("checkOutTime")
    @ColumnInfo(name = "CheckOutTime")
    var checkOutTime: String?,

    @SerializedName("date")
    @ColumnInfo(name = "Date")
    var date: String,

    @SerializedName("latitude")
    @ColumnInfo(name = "Latitude")
    var latitude: String,

    @SerializedName("longitude")
    @ColumnInfo(name = "Longitude")
    var longitude: String,

    @SerializedName("applicationId")
    @ColumnInfo(name = "ApplicationID")
    var applicationId: String
){
    @PrimaryKey(autoGenerate = true)
    var id: Long = 0
}
