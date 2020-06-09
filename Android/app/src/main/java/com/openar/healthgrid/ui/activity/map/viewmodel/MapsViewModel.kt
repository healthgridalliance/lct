package com.openar.healthgrid.ui.activity.map.viewmodel

import android.Manifest
import android.location.Location
import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.google.android.gms.maps.model.LatLng
import com.openar.healthgrid.Constants
import com.openar.healthgrid.Constants.HEALTH_GRID_API
import com.openar.healthgrid.HealthGridApplication
import com.openar.healthgrid.api.entity.HeatMapObject
import com.openar.healthgrid.api.entity.HeatMapPoints
import com.openar.healthgrid.database.LocationInfoProvider
import com.openar.healthgrid.repository.ApiRequestsRepository
import com.openar.healthgrid.repository.CheckExposureRepository
import com.openar.healthgrid.service.SaveLocationDataService
import com.openar.healthgrid.util.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.io.Serializable


class MapsViewModel : ViewModel(), ApiContract.ViewModel, Serializable {
    private var apiRequestsRepository: ApiRequestsRepository? = ApiRequestsRepository()
    val trackingStatusId: MutableLiveData<Int> by lazy {
        MutableLiveData(-1).also {
            loadTrackingStatusValue()
        }
    }
    val exposureInfo: MutableLiveData<MutableMap<String, Int>?> = MutableLiveData(null)
    private val lastKnownLocation: MutableLiveData<Location> = MutableLiveData<Location>()
//  TODO replace with next string when server call will work correctly
    private val heatMapList: MutableLiveData<MutableList<HeatMapPoints>> = MutableLiveData<MutableList<HeatMapPoints>>()
//    private val heatMapList: MutableLiveData<MutableList<HeatMapObject>> = MutableLiveData<MutableList<HeatMapObject>>()
    private var localInfectedLocations: HeatMapObject? = null
    private var bottomSheetOpened: MutableLiveData<Boolean> = MutableLiveData(false)

    fun initApp() {
        apiRequestsRepository?.getHeatZones()
        setHeatMapList(loadMainTestHeatZones("HeatMap0DaysAgo.json"))
    }

    private fun loadTrackingStatusValue() {
        CoroutineScope(Dispatchers.Default).launch {
            val status = PreferenceStorage.getPropertyInt(
                HealthGridApplication.getApplicationContext(),
                PreferenceStorage.TRACKING_STATUS_VALUE
            )
            if (status == -1) {
                trackingStatusId.postValue(Constants.INACTIVE_TRACKING_STATUS)
            } else {
                if (PermissionUtils.isPermissionGranted(HealthGridApplication.getApplicationContext(), Manifest.permission.ACCESS_FINE_LOCATION)
                ) {
                    trackingStatusId.postValue(status)
                } else {
                    trackingStatusId.postValue(Constants.INACTIVE_TRACKING_STATUS)
                }
            }
            PreferenceStorage.addPropertyInt(
                HealthGridApplication.getApplicationContext(),
                PreferenceStorage.TRACKING_STATUS_VALUE,
                trackingStatusId.value ?: Constants.INACTIVE_TRACKING_STATUS
            )
        }
    }

    fun isBottomSheetOpened(): LiveData<Boolean> = bottomSheetOpened

    fun setBottomSheetOpenedStatus(opened: Boolean) {
        bottomSheetOpened.value = opened
    }

    fun getLastKnownLocation(): LiveData<Location> = lastKnownLocation

    fun setLastKnownLocation(location: Location) {
        lastKnownLocation.value = location
    }

    fun setTrackingStatusId(id: Int) {
            trackingStatusId.value = id
            PreferenceStorage.addPropertyInt(
                HealthGridApplication.getApplicationContext(),
                PreferenceStorage.TRACKING_STATUS_VALUE,
                id
            )
    }

    fun getHeatMapList(pos: Int): MutableList<LatLng>? = heatMapList.value?.get(pos)?.points ?: mutableListOf()

    private fun loadMainTestHeatZones(fileName: String): LocationList =
        FileReadUtils.readJsonFile(fileName, HealthGridApplication.getApplicationContext())

    fun onExposureButtonTap() {
        for(daysBefore in 0..Constants.DAYS_BEFORE_TODAY)
            apiRequestsRepository?.getLocalHeatZones(lastKnownLocation.value, DateUtils.getDateDaysBefore(daysBefore))
        exposureInfo.value = mutableMapOf("20 May 2020" to 0, "3 June 2020" to 0, "13 June 2020" to 0)
    }

    fun loadTestData() {
        setHeatMapList(loadMainTestHeatZones("HeatMap1DaysAgo.json"))
        setHeatMapList(loadMainTestHeatZones("HeatMap2DaysAgo.json"))
    }

    fun deleteButtonTapped() {
        SaveLocationDataService.instance.deleteAllData()
        apiRequestsRepository?.deleteAllData()
    }

    fun onFirstAppLaunch() {
        apiRequestsRepository?.registerApp()
    }

    fun onInfectedStatusChanged(infected: Boolean) {
        apiRequestsRepository?.changeInfectedStatus(infected)
        sendLocationListIfNeeded(infected)
    }

    private fun setHeatMapList(heatMap: LocationList) {
        val list = HeatMapPoints()
        for(loc in heatMap.tagIds) {
            try {
                if(loc?.lat != null && loc.lng != null) {
                    list.points.add(LatLng(loc.lat!!.toDouble(), loc.lng!!.toDouble()))
                }
            } catch (ex: Exception) {}
        }
        var newData = heatMapList.value
        if(newData == null) newData = mutableListOf()
        newData.add(list)
        heatMapList.value = newData
    }


    private fun sendLocationListIfNeeded(infected: Boolean) {
        if (infected) {
            CoroutineScope(Dispatchers.Default).launch {
                SaveLocationDataService.instance.updateLastObjectCheckOutTime(DateUtils.getCalendar().timeInMillis)
                LocationInfoProvider.instance?.deleteExpiredData(Constants.KEEP_MAX_HOURS)
                val locationList = LocationInfoProvider.instance?.getAllData()
                locationList?.let {
                    apiRequestsRepository?.sendLocationList(locationList)
                }
            }
        }
    }

    private fun onFoundExposure(info: Pair<String, Int>) {
        if(exposureInfo.value == null) {
            exposureInfo.value = mutableMapOf()
        }
        val curInfo = exposureInfo.value
        curInfo?.put(info.first, info.second)
        exposureInfo.postValue(curInfo)
    }

    override fun onError(error: String) {
        Log.e(HEALTH_GRID_API, error)
    }

    override fun onAppRegistered() {}

    override fun onSuccessfulRequest(msg: String?) {
        msg?.let { Log.d(HEALTH_GRID_API, msg) }
    }

    override fun onHeatZonesUpdated(heatZones: HeatMapObject?) {
//        TODO uncomment  when server call will work correctly
//        heatMapList = heatZones
    }

    override fun onLocalHeatZonesUpdated(infectedLocations: HeatMapObject?) {
        infectedLocations?.let { CheckExposureRepository(it).checkExposure(this::onFoundExposure) }
    }

    override fun onCleared() {
        apiRequestsRepository?.unsubscribe()
        apiRequestsRepository = null
        super.onCleared()
    }

    init {
        apiRequestsRepository?.subscribe(this)
    }
}