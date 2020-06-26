package com.openar.healthgrid.repository

import android.location.Location
import android.util.Log
import com.openar.healthgrid.Constants
import com.openar.healthgrid.HealthGridApplication
import com.openar.healthgrid.api.HealthGridService
import com.openar.healthgrid.api.entity.LocationInfoObject
import com.openar.healthgrid.database.LocationInfoEntity
import com.openar.healthgrid.ui.activity.map.viewmodel.ApiContractBase
import com.openar.healthgrid.ui.activity.map.viewmodel.ApiContractHeatZones
import com.openar.healthgrid.util.PreferenceStorage
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.disposables.CompositeDisposable
import io.reactivex.rxjava3.schedulers.Schedulers

class ApiRequestsRepository: ApiContractBase.Repository, ApiContractHeatZones.Repository {
    private val subscriptions = CompositeDisposable()
    private val service: HealthGridService = HealthGridService.instance
    private var viewModel: ApiContractBase.ViewModel? = null
    private var heatZonesModel: ApiContractHeatZones.ViewModel? = null

    fun subscribe(viewModel: ApiContractBase.ViewModel? = null, heatZonesModel: ApiContractHeatZones.ViewModel? = null) {
        this.viewModel = viewModel
        this.heatZonesModel = heatZonesModel
    }

    fun unsubscribe(viewModel: Boolean = true) {
        if(viewModel) this.viewModel = null else this.heatZonesModel = null
        subscriptions.clear()
    }

    override fun deleteAllData() {
        val testId = PreferenceStorage.getPropertyString(HealthGridApplication.getApplicationContext(), PreferenceStorage.TEST_ID)
        val subscription = service.deleteAllData(testId)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                { res ->
                    viewModel?.onSuccessfulRequest(res.message)
                    Log.d(HealthGridService.TAG, "DELETE api/LocationHistory/ SUCCESS")
                },
                { error ->
                    viewModel?.onError(error?.message ?: Constants.NO_MESSAGE)
                    Log.d(HealthGridService.TAG, "DELETE api/LocationHistory/ ERROR")
                }
            )
        subscriptions.add(subscription)
    }

    override fun sendLocationList(locationList: List<LocationInfoEntity>, testId: String) {
        val testId = PreferenceStorage.getPropertyString(HealthGridApplication.getApplicationContext(), PreferenceStorage.TEST_ID)
        val body = mutableListOf<LocationInfoObject>()
        locationList.forEach { obj ->
            body.add(
                LocationInfoObject(
                    testId,
                    obj.checkInTime,
                    obj.checkOutTime,
                    obj.date,
                    obj.latitude,
                    obj.longitude
                )
            )
        }
        val subscription = service.sendLocationList(body)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                { res ->
                    viewModel?.onSuccessfulRequest(res.message)
                    Log.d(HealthGridService.TAG, "POST api/LocationHistory SUCCESS")
                },
                { error ->
                    viewModel?.onError(error?.message ?: Constants.NO_MESSAGE)
                    Log.d(HealthGridService.TAG, "POST api/LocationHistory ERROR")
                }
            )
        subscriptions.add(subscription)
    }

    override fun getHeatZones(latLng: Location?, date: String, needCheckExposure: Boolean) {
        latLng?.let {
            val subscription = service.getHeatZones(latLng.latitude.toString(), latLng.longitude.toString(), date)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(
                        { heatZones ->
                            heatZonesModel?.onHeatZonesUpdated(heatZones, needCheckExposure)
                            Log.d(HealthGridService.TAG, "GET api/HeatZones/Get SUCCESS")
                        },
                        { error ->
                            heatZonesModel?.onGetHeatZonesError(error?.message ?: Constants.NO_MESSAGE)
                            Log.d(HealthGridService.TAG, "GET api/HeatZones/Get ERROR")
                        }
                    )
            subscriptions.add(subscription)
        }
    }

    override fun getInitialAppParameters() {
        val subscription = service.getInitialAppParameters()
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                { parameters ->
                    viewModel?.onGetAppParameters(parameters)
                    Log.d(HealthGridService.TAG, "GET api/AppSetting/Get SUCCESS")
                },
                { error ->
                    viewModel?.onError(error?.message ?: Constants.NO_MESSAGE)
                    Log.d(HealthGridService.TAG, "GET api/AppSetting/Get ERROR")
                }
            )
        subscriptions.add(subscription)
    }
}
