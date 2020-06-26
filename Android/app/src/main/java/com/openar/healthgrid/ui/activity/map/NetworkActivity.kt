package com.openar.healthgrid.ui.activity.map

import android.content.IntentFilter
import android.net.ConnectivityManager
import android.os.Bundle
import androidx.lifecycle.Observer
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.BaseActivity
import com.openar.healthgrid.ui.activity.NetworkBroadcastReceiver
import com.openar.healthgrid.util.OfflineNotificationUtils
import kotlinx.android.synthetic.main.no_connection_alert.*

abstract class NetworkActivity : BaseActivity() {
    private lateinit var networkBroadcastReceiver: NetworkBroadcastReceiver
    protected var hasNetworkConnection: Boolean = true

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_maps)
        mapsViewModel.isBottomSheetOpened().observe(this, Observer { opened ->
            if (opened) {
                OfflineNotificationUtils.removeSnackBarMessage(top_coordinator, this)
            }
        })
    }

    override fun onStart() {
        super.onStart()
        networkBroadcastReceiver = NetworkBroadcastReceiver(top_coordinator, mapsViewModel.isBottomSheetOpened())
        val filter = IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION)
        registerReceiver(networkBroadcastReceiver, filter)
    }

    override fun onStop() {
        unregisterReceiver(networkBroadcastReceiver)
        super.onStop()
    }
}