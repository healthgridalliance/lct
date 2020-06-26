package com.openar.healthgrid.ui.activity.map.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel

class InfectedStatusViewModel : ViewModel() {
    private val idLength: MutableLiveData<Int> = MutableLiveData<Int>(0)
    var testId: String = ""

    fun getIdLength(): LiveData<Int> = idLength

    fun setIdLength(length: Int) {
        idLength.value = length
    }

    companion object {
        const val MAX_ID_LENGTH = 6
    }
}