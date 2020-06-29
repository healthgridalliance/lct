package com.openar.healthgrid.util

import com.google.android.gms.maps.model.LatLng
import com.openar.healthgrid.api.entity.CustomLatLng

object TypeConvertUtils {

    fun toGoogleLatLng(customLatLng: List<CustomLatLng>): MutableList<LatLng> {
        val latLngList = mutableListOf<LatLng>()
        customLatLng.forEach { customPoint ->
            try {
                latLngList.add(LatLng(customPoint.latitude!!.toDouble(), customPoint.longitude!!.toDouble()))
            } catch (ex: Exception) {}
        }
        return latLngList
    }

}