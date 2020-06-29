package com.openar.healthgrid.ui.activity.exposure

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.google.android.gms.maps.model.LatLng
import com.openar.healthgrid.api.entity.HeatMapObject
import com.openar.healthgrid.repository.ApiRequestsRepository
import com.openar.healthgrid.repository.CheckExposureRepository
import com.openar.healthgrid.repository.HeatZonesRepository
import com.openar.healthgrid.ui.activity.map.viewmodel.ApiContractHeatZones
import com.openar.healthgrid.util.DateUtils
import com.openar.healthgrid.util.TypeConvertUtils

class HeatZonesViewModel : ViewModel(), ApiContractHeatZones.ViewModel {
    private var apiRequestsRepository: ApiRequestsRepository? = ApiRequestsRepository()
    private var heatMapList: MutableLiveData<MutableMap<String, List<LatLng>>> = MutableLiveData(mutableMapOf())
    private val requestCount: MutableLiveData<Int> = MutableLiveData(0)
    private var count = 0
    private val noLocationTrigger: MutableLiveData<Boolean> = MutableLiveData(false)

    fun updateTodayHeatZones() {
        HeatZonesRepository.instance.getHeatZones(apiRequestsRepository, this::noLocationCallback)
    }

    fun updateHeatZones() {
        HeatZonesRepository.instance.getLastKnownLocationAndCheckExposure(apiRequestsRepository, this::noLocationCallback, false)
    }

    fun getNoLocationTrigger(): LiveData<Boolean> = noLocationTrigger
    fun getRequestCount(): LiveData<Int> = requestCount
    fun getHeatMapList(): LiveData<MutableMap<String, List<LatLng>>> = heatMapList

    fun resetNoLocationTrigger() {
        noLocationTrigger.value = false
    }

    fun onExposureCheckTap() {
        count = 0
        requestCount.value = 0
        HeatZonesRepository.instance.getLastKnownLocationAndCheckExposure(apiRequestsRepository, this::noLocationCallback,true)
    }

    private fun noLocationCallback() {
        noLocationTrigger.value = true
    }

    override fun onError(error: String) {
    }

    @Synchronized override fun onGetHeatZonesError(error: String) {
        requestCount.postValue(++count)
        Log.d("ApiRequest", requestCount.value.toString())
    }

    override fun onHeatZonesUpdated(infectedLocations: HeatMapObject, needCheckExposure: Boolean) {
        infectedLocations.data?.let {
            val heatMap = heatMapList.value
            it.date?.let { date -> it.points?.let { zones -> heatMap?.put(date, TypeConvertUtils.toGoogleLatLng(zones)) } }
            heatMapList.value = heatMap
        }
        if(needCheckExposure)
            CheckExposureRepository(infectedLocations).checkExposure(this::onFoundExposure)
    }

    @Synchronized private fun onFoundExposure(info: Pair<String, Int>) {
        requestCount.postValue(++count)
        Log.d("ApiRequest", requestCount.value.toString())
        if(info.second > 0) {
            HeatZonesRepository.instance.saveExposureResult(info)
        }
    }

    override fun onCleared() {
        apiRequestsRepository?.unsubscribe(false)
        apiRequestsRepository = null
        super.onCleared()
    }

    fun getHeatMapList(pos: Int): List<LatLng> = heatMapList.value?.get(DateUtils.getDateDaysBefore(pos)) ?: listOf()

    init {
        apiRequestsRepository?.subscribe(heatZonesModel = this)
    }
}