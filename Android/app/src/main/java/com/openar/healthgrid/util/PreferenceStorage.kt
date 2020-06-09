package com.openar.healthgrid.util

import android.annotation.SuppressLint
import android.content.Context
import android.content.SharedPreferences

object PreferenceStorage {
    private const val STORAGE_NAME = "base_storage"

    const val FIRST_LAUNCH = "first_launch"
    const val HEALTH_STATUS_VALUE = "health_status_value"
    const val TRACKING_STATUS_VALUE = "tracking_status_value"
    const val TRACKING_STARTED_FLAG = "TRACKING_STARTED_FLAG"
    const val NEED_ACTIVATE_TRACKING = "NEED_ACTIVATE_TRACKING"

    private var storage: SharedPreferences? = null
    private var editor: SharedPreferences.Editor? = null

    @SuppressLint("CommitPrefEdits")
    private fun init(context: Context) {
        if (storage == null) {
            storage = context.getSharedPreferences(STORAGE_NAME, Context.MODE_PRIVATE)
            editor = storage?.edit()
        }
    }

    fun addPropertyBoolean(context: Context, name: String, value: Boolean) {
        init(context)
        editor?.putBoolean(name, value)
        editor?.apply()
    }

    fun getPropertyBooleanTrue(context: Context, name: String?): Boolean {
        init(context)
        return storage?.getBoolean(name, java.lang.Boolean.TRUE) ?: java.lang.Boolean.TRUE
    }

    fun getPropertyBooleanFalse(context: Context, name: String): Boolean {
        init(context)
        return storage?.getBoolean(name, java.lang.Boolean.FALSE) ?: java.lang.Boolean.FALSE
    }

    fun addPropertyInt(context: Context, name: String, value: Int) {
        init(context)
        editor?.putInt(name, value)
        editor?.apply()
    }

    fun getPropertyInt(context: Context, name: String?): Int {
        init(context)
        return storage?.getInt(name, -1) ?: -1
    }
}