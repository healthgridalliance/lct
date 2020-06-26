package com.openar.healthgrid.ui.activity.map.dialog.bottomsheet

import android.content.IntentFilter
import android.net.ConnectivityManager
import android.os.Bundle
import android.view.View
import androidx.fragment.app.activityViewModels
import com.openar.healthgrid.ui.activity.NetworkBroadcastReceiver
import com.openar.healthgrid.ui.activity.map.dialog.bottomsheet.BaseBottomSheetDialog
import com.openar.healthgrid.ui.activity.map.viewmodel.MapsViewModel
import kotlinx.android.synthetic.main.no_connection_alert.*

abstract class NetworkBottomSheet : BaseBottomSheetDialog(){
    protected val mapsViewModel: MapsViewModel by activityViewModels()
    private lateinit var networkBroadcastReceiver: NetworkBroadcastReceiver

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        networkBroadcastReceiver = NetworkBroadcastReceiver(top_coordinator)
        val filter = IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION)
        requireContext().registerReceiver(networkBroadcastReceiver, filter)
    }

    override fun onDestroy() {
        requireContext().unregisterReceiver(networkBroadcastReceiver)
        super.onDestroy()
    }
}