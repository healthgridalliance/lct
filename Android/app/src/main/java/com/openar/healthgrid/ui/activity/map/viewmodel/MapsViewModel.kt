package com.openar.healthgrid.ui.activity.map.viewmodel

import android.Manifest
import android.content.Context
import android.location.Location
import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationResult
import com.openar.healthgrid.Constants
import com.openar.healthgrid.Constants.HEALTH_GRID_API
import com.openar.healthgrid.HealthGridApplication
import com.openar.healthgrid.api.entity.AppParametersObject
import com.openar.healthgrid.database.LocationInfoProvider
import com.openar.healthgrid.repository.ApiRequestsRepository
import com.openar.healthgrid.service.SaveLocationDataService
import com.openar.healthgrid.util.DateUtils
import com.openar.healthgrid.util.PermissionUtils
import com.openar.healthgrid.util.PreferenceStorage
import com.openar.healthgrid.util.UpdateLocationUtils
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MapsViewModel : ViewModel(), ApiContractBase.ViewModel {
    private var apiRequestsRepository: ApiRequestsRepository? = ApiRequestsRepository()
    val trackingStatusId: MutableLiveData<Int> = MutableLiveData(-1)
    private val lastKnownLocation: MutableLiveData<Location> = MutableLiveData()
    private var bottomSheetOpened: MutableLiveData<Boolean> = MutableLiveData(false)
    private var hasPermission = false

    fun initApplication() {
        apiRequestsRepository?.getInitialAppParameters()
    }

    fun loadTrackingStatusValue(context: Context) {
        CoroutineScope(Dispatchers.Default).launch {
            hasPermission = PermissionUtils.isPermissionGranted(HealthGridApplication.getApplicationContext(), Manifest.permission.ACCESS_FINE_LOCATION)
            PermissionUtils.checkGeolocationServicesSwitchedOn(
                context,
                showDialog = false,
                successCallback = { res ->
                    var status = -1
                    if (hasPermission && res) {
                        status = PreferenceStorage.getPropertyInt(
                            HealthGridApplication.getApplicationContext(),
                            PreferenceStorage.TRACKING_STATUS_VALUE
                        )
                        if (status == -1) {
                            trackingStatusId.postValue(Constants.ACTIVE_TRACKING_STATUS)
                        } else {
                            trackingStatusId.postValue(status)
                        }
                    } else {
                        status = Constants.INACTIVE_TRACKING_STATUS
                        trackingStatusId.postValue(Constants.INACTIVE_TRACKING_STATUS)
                    }
                    PreferenceStorage.addPropertyInt(
                        HealthGridApplication.getApplicationContext(),
                        PreferenceStorage.TRACKING_STATUS_VALUE,
                        if (status == -1) Constants.ACTIVE_TRACKING_STATUS else status
                    )
                })
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

    fun deleteButtonTapped() {
        SaveLocationDataService.instance.deleteAllData()
        apiRequestsRepository?.deleteAllData()
    }

    fun sendLocationList(testId: String) {
            CoroutineScope(Dispatchers.Default).launch {
                val locationCallback: LocationCallback = object : LocationCallback() {
                    override fun onLocationResult(locationResult: LocationResult?) {
                        if (locationResult != null) {
                            SaveLocationDataService.instance.saveLocationIfNeeded(locationResult.locations)
                            SaveLocationDataService.instance.updateLastObjectCheckOutTime(DateUtils.getCalendar().timeInMillis)
                            val locationList = LocationInfoProvider.instance?.getAllData()
                            locationList?.let {
                                apiRequestsRepository?.sendLocationList(locationList, testId)
                            }
                        }
                    }
                }

                SaveLocationDataService.instance.updateLastObjectCheckOutTime(DateUtils.getCalendar().timeInMillis)
                LocationInfoProvider.instance?.deleteExpiredData(Constants.KEEP_MAX_HOURS)
                val locationList = LocationInfoProvider.instance?.getAllData()
                locationList?.let {
                    if(locationList.isNotEmpty())
                        apiRequestsRepository?.sendLocationList(locationList, testId)
                    else {
                        UpdateLocationUtils().getCurrentLocation(HealthGridApplication.getApplicationContext(), locationCallback)
                    }
                }
            }
    }

    override fun onError(error: String) {
        Log.e(HEALTH_GRID_API, error)
    }

    override fun onAppRegistered() {}

    override fun onSuccessfulRequest(msg: String?) {
        msg?.let { Log.d(HEALTH_GRID_API, msg) }
    }

    override fun onGetAppParameters(parameters: AppParametersObject) {
        PreferenceStorage.addPropertyString(
            HealthGridApplication.getApplicationContext(),
            PreferenceStorage.LEGEND_MAX_COLOR,
            parameters.data?.maxColor ?: ""
        )
        PreferenceStorage.addPropertyString(
            HealthGridApplication.getApplicationContext(),
            PreferenceStorage.LEGEND_MIN_COLOR,
            parameters.data?.minColor ?: ""
        )
        PreferenceStorage.addPropertyInt(
            HealthGridApplication.getApplicationContext(),
            PreferenceStorage.MAX_EXPOSURE_DISTANCE_METERS,
            parameters.data?.exposureDistance ?: Constants.MAX_DISTANCE_EXPOSURE_METER
        )
    }

    override fun onCleared() {
        apiRequestsRepository?.unsubscribe()
        apiRequestsRepository = null
        super.onCleared()
    }

    init {
        apiRequestsRepository?.subscribe(viewModel = this)
    }
}