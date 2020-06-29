package com.openar.healthgrid.ui.activity.map.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.openar.healthgrid.Constants
import com.openar.healthgrid.model.HistoryDateItem
import com.openar.healthgrid.service.DateService


class HistoryViewModel : ViewModel() {
    private val activeDays: MutableLiveData<Int> = MutableLiveData<Int>(Constants.DAYS_BEFORE_TODAY)
    private val daysBefore: MutableLiveData<Int> = MutableLiveData<Int>(24)
    private val historyDates: MutableLiveData<List<HistoryDateItem>> =
        MutableLiveData<List<HistoryDateItem>>(loadHistoryDates())

    fun getHistoryDates(): LiveData<List<HistoryDateItem>> = historyDates

    fun getActiveDaysNumber(): LiveData<Int> = activeDays

    private fun loadHistoryDates() = DateService.instance.loadHistoryDates(daysBefore.value ?: 0)

}