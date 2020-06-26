package com.openar.healthgrid.ui.activity.exposure

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel

class PermissionsViewModel : ViewModel() {
    private var locationSwitchedOn: Boolean = false
    private var hasLocationPermission: Boolean = false
    private val commonLocationOn: MutableLiveData<Boolean> = MutableLiveData<Boolean>(false)
    private var isWelcomeVisible: Boolean = false
    var settingsOpened = false

    fun isLocationSwitchedOn(): LiveData<Boolean> = commonLocationOn

    fun setLocationSwitchedOnStatus(switchedOn: Boolean) {
        locationSwitchedOn = switchedOn
        checkCommonLocationStatus()
    }

    fun setLocationPermissionStatus(hasPermission: Boolean) {
        hasLocationPermission = hasPermission
        checkCommonLocationStatus()
    }

    private fun checkCommonLocationStatus() {
        commonLocationOn.value = locationSwitchedOn && hasLocationPermission
    }

    fun setWelcomeVisibleStatus(visible: Boolean) {
        isWelcomeVisible = visible
    }

    fun isWelcomeVisible() = isWelcomeVisible
}