package com.openar.healthgrid.util

import android.annotation.SuppressLint
import android.content.Context
import android.net.ConnectivityManager
import android.view.MotionEvent
import android.view.View

object OfflineNotificationUtils {
    @SuppressLint("ClickableViewAccessibility")
    fun showSnackBarMessage(view: View, context: Context) {
        view.visibility = View.VISIBLE
        view.animate().setDuration(400L).translationY(85 * context.resources.displayMetrics.density)

        var y = 0f
        view.setOnTouchListener { v, event ->

            when (event.action) {
                MotionEvent.ACTION_DOWN ->
                    y = event.y
                MotionEvent.ACTION_MOVE -> {
                    val distance = y - event.y
                    if(distance > 80) {
                        removeSnackBarMessage(v, context)
                    }
                }
            }
            true
        }
    }

    fun removeSnackBarMessage(view: View, context: Context) {
        view.animate().setDuration(700L).translationYBy(-85 * context.resources.displayMetrics.density)
        view.visibility = View.GONE
    }

    fun verifyAvailableNetwork(context: Context): Boolean {
        val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val networkInfo = connectivityManager.activeNetworkInfo
        return  networkInfo != null && networkInfo.isConnected
    }
}