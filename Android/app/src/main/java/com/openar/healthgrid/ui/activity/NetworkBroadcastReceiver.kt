package com.openar.healthgrid.ui.activity

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.view.View
import androidx.lifecycle.LiveData
import com.openar.healthgrid.util.OfflineNotificationUtils

class NetworkBroadcastReceiver(private val view: View, private val bottomSheetOpened: LiveData<Boolean>? = null) : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val noInternet =  intent.getBooleanExtra(ConnectivityManager.EXTRA_NO_CONNECTIVITY, false)
        if(noInternet) {
            if(bottomSheetOpened == null) {
                OfflineNotificationUtils.showSnackBarMessage(view, context)
            } else if(bottomSheetOpened.value == false)
                OfflineNotificationUtils.showSnackBarMessage(view, context)
        } else {
            OfflineNotificationUtils.removeSnackBarMessage(view, context)
        }
    }
}