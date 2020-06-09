package com.openar.healthgrid.repository

import android.location.Location
import android.util.Log
import com.openar.healthgrid.Constants
import com.openar.healthgrid.api.HealthGridService
import com.openar.healthgrid.database.LocationInfoEntity
import com.openar.healthgrid.ui.activity.map.viewmodel.ApiContract
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.disposables.CompositeDisposable
import io.reactivex.rxjava3.schedulers.Schedulers

class ApiRequestsRepository: ApiContract.Repository {
    private val subscriptions = CompositeDisposable()
    private val service: HealthGridService = HealthGridService.instance
    private var viewModel: ApiContract.ViewModel? = null

    fun subscribe(viewModel: ApiContract.ViewModel) {
        this.viewModel = viewModel
    }

    fun unsubscribe() {
        this.viewModel = null
        subscriptions.clear()
    }

    override fun registerApp() {
        val subscription = service.getAppId()
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                {
                    viewModel?.onAppRegistered()
                    Log.d(HealthGridService.TAG, "POST api/COVID19App SUCCESS")
                },
                { error ->
                    viewModel?.onError(error?.message ?: Constants.NO_MESSAGE)
                    Log.d(HealthGridService.TAG, "POST api/COVID19App ERROR")
                }
            )
        subscriptions.add(subscription)
    }

    override fun changeInfectedStatus(infected: Boolean) {
        val subscription = service.changeInfectedStatus(infected)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                { res ->
                    viewModel?.onSuccessfulRequest(res.message)
                    Log.d(HealthGridService.TAG, "POST api/COVID19Status SUCCESS")
                },
                { error ->
                    viewModel?.onError(error?.message ?: Constants.NO_MESSAGE)
                    Log.d(HealthGridService.TAG, "POST api/COVID19Status ERROR")
                }
            )
        subscriptions.add(subscription)
    }

    override fun deleteAllData() {
        val subscription = service.deleteAllData()
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

    override fun sendLocation(location: LocationInfoEntity) {
        val subscription = service.sendLocation(location)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                { res ->
                    viewModel?.onSuccessfulRequest(res.message)
                    Log.d(HealthGridService.TAG, "POST api/LocationHistory/ SUCCESS")
                },
                { error ->
                    viewModel?.onError(error?.message ?: Constants.NO_MESSAGE)
                    Log.d(HealthGridService.TAG, "POST api/LocationHistory/ ERROR")
                }
            )
        subscriptions.add(subscription)
    }

    override fun sendLocationList(locationList: List<LocationInfoEntity>) {
        val subscription = service.sendLocationList(locationList)
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

    override fun getHeatZones() {
        val subscription = service.getHeatZones()
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                { heatZones ->
                    viewModel?.onHeatZonesUpdated(heatZones)
                    Log.d(HealthGridService.TAG, "GET api/HeatZones/Get SUCCESS")
                },
                { error ->
                    viewModel?.onError(error?.message ?: Constants.NO_MESSAGE)
                    Log.d(HealthGridService.TAG, "GET api/HeatZones/Get ERROR")
                }
            )
        subscriptions.add(subscription)
    }

    override fun getLocalHeatZones(latLng: Location?, date: String) {
        latLng?.let {
            val subscription = service.getLocalHeatZones(latLng.latitude.toString(), latLng.longitude.toString(), date)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                    { heatZones ->
                        Log.d(HealthGridService.TAG, "POST api/HeatZones SUCCESS")
                        viewModel?.onLocalHeatZonesUpdated(heatZones)
                    },
                    { error ->
                        viewModel?.onError(error?.message ?: Constants.NO_MESSAGE)
                        Log.d(HealthGridService.TAG, "POST api/HeatZones ERROR")
                    }
                )
            subscriptions.add(subscription)
        }
    }
}
