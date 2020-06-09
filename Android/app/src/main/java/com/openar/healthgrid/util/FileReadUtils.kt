package com.openar.healthgrid.util

import android.content.Context
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import kotlinx.coroutines.runBlocking
import java.io.InputStream

object FileReadUtils {
    fun readJsonFile(name: String, context: Context): LocationList {
        val res: LocationList
        runBlocking {
            var json: String? = null
            try {
                val inputStream: InputStream = context.assets.open(name)
                json = inputStream.bufferedReader().use { it.readText() }
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
            res = parseJson(json, LocationList::class.java)
        }
        return res
    }

    fun <T> parseJson(json: String?, classObj: Class<T>): T {
        return Gson().fromJson(json, classObj)
    }
}

data class LocationList(
    @SerializedName("list")
    var tagIds: List<Location?> = listOf()
)

data class Location(

    @SerializedName("lat")
    var lat: String? = null,

    @SerializedName("lng")
    var lng: String? = null
)