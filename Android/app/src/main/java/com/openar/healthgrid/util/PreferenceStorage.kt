package com.openar.healthgrid.util

import android.annotation.SuppressLint
import android.content.Context
import android.content.SharedPreferences

object PreferenceStorage {
    private const val STORAGE_NAME = "base_storage"

    const val FIRST_LAUNCH = "first_launch"
    const val USER_TRACKING_STATUS_VALUE = "user_tracking_status_value"
    const val TRACKING_STATUS_VALUE = "tracking_status_value"
    const val TRACKING_STARTED_FLAG = "tracking_started_flag"
    const val NEED_ACTIVATE_TRACKING = "need_activate_tracking"
    const val TEST_ID = "test_id"
    const val SETTINGS_DIALOG_VISIBLE = "settings_dialog_visible"
    const val GEOLOCATION_DIALOG_VISIBLE = "geolocation_dialog_visible"
    const val LEGEND_MIN_COLOR = "legend_min_color"
    const val LEGEND_MAX_COLOR = "legend_max_color"
    const val MAX_EXPOSURE_DISTANCE_METERS = "max_exposure_distance_meters"
    const val NEED_LOAD_SETTINGS = "need_load_settings"

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

    fun addPropertyString(context: Context, name: String, value: String) {
        init(context)
        editor?.putString(name, value)
        editor?.apply()
    }

    fun getPropertyString(context: Context, name: String?): String {
        init(context)
        return storage?.getString(name, "") ?: ""
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