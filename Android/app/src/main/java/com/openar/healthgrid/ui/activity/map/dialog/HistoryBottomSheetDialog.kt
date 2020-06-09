package com.openar.healthgrid.ui.activity.map.dialog

import android.content.IntentFilter
import android.content.pm.PackageManager
import android.location.Location
import android.net.ConnectivityManager
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.AbsListView
import androidx.fragment.app.activityViewModels
import androidx.fragment.app.viewModels
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.SnapHelper
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.LocationSource
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.SupportMapFragment
import com.openar.healthgrid.Constants
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.NetworkBroadcastReceiver
import com.openar.healthgrid.ui.activity.map.HistoryDayChangeListener
import com.openar.healthgrid.ui.activity.map.MapsMainActivity
import com.openar.healthgrid.ui.activity.map.controller.MapController
import com.openar.healthgrid.ui.activity.map.dialog.adapter.DateListAdapter
import com.openar.healthgrid.ui.activity.map.dialog.adapter.EndSnapHelper
import com.openar.healthgrid.ui.activity.map.viewmodel.HistoryViewModel
import com.openar.healthgrid.ui.activity.map.viewmodel.MapsViewModel
import com.openar.healthgrid.util.WorkUtils
import kotlinx.android.synthetic.main.dialog_header.*
import kotlinx.android.synthetic.main.modal_bottom_sheet_history.*
import kotlinx.android.synthetic.main.no_connection_alert.*

class HistoryBottomSheetDialog private constructor(): BaseBottomSheetDialog(), OnMapReadyCallback,
    LocationSource.OnLocationChangedListener, HistoryDayChangeListener {
    private lateinit var recyclerView: RecyclerView
    private lateinit var viewAdapter: RecyclerView.Adapter<*>
    private lateinit var viewManager: RecyclerView.LayoutManager
    private lateinit var endSnapHelper: SnapHelper
    private val viewModel: HistoryViewModel by viewModels()
    private var mapController: MapController? = null
    private val mapsViewModel: MapsViewModel by activityViewModels()
    private var keepOpenedStatus = false

    private lateinit var networkBroadcastReceiver: NetworkBroadcastReceiver

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        loadTestData()
        val view: View = inflater.inflate(R.layout.modal_bottom_sheet_history, container, false)
        val mapFragment = childFragmentManager.findFragmentById(R.id.history_map) as SupportMapFragment
        mapFragment.getMapAsync(this)
        constructTimeLine(view)
        super.onCreateView(view)
        return view
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        networkBroadcastReceiver = NetworkBroadcastReceiver(top_coordinator)
        val filter = IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION)
        requireContext().registerReceiver(networkBroadcastReceiver, filter)
        header_title.text = getString(R.string.history_title)
        date_picker_container.setOnClickListener { prepareToolTipDialogForShowing() }
        legend_exit.setOnClickListener {
            dismiss()
            keepOpenedStatus = true
            val bottomSheet = ConfigurationBottomSheetDialog.newInstance()
            activity?.supportFragmentManager?.let {
                bottomSheet.show(it, ConfigurationBottomSheetDialog.BOTTOM_SHEET_TAG)
            }
        }
    }

    override fun onMapReady(googleMap: GoogleMap) {
        mapController = MapController(mapsViewModel)
        mapController?.configureMap(googleMap, requireActivity(), false)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when (requestCode) {
            MapsMainActivity.LOCATION_PERMISSION_REQUEST_CODE -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    mapsViewModel.setTrackingStatusId(Constants.ACTIVE_TRACKING_STATUS)
                    WorkUtils.startBackgroundJob(requireContext())
                    mapController?.enableUserLocation(requireActivity())
                }
                return
            }
        }
    }

    private fun loadTestData() = mapsViewModel.loadTestData()

    private fun constructTimeLine(view: View) {
        viewManager = LinearLayoutManager(context, RecyclerView.HORIZONTAL, true)
        context?.let { viewAdapter = DateListAdapter(it, viewModel, this) }
        recyclerView = view.findViewById(R.id.date_recycler_view)
        recyclerView.apply {
            canScrollVertically(0)
            setHasFixedSize(true)
            layoutManager = viewManager
            adapter = viewAdapter
            isNestedScrollingEnabled = false
        }
        endSnapHelper = EndSnapHelper(viewModel.getActiveDaysNumber().value ?: 0)
        endSnapHelper.attachToRecyclerView(recyclerView)
        recyclerView.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                super.onScrollStateChanged(recyclerView, newState)
                if (newState == AbsListView.OnScrollListener.SCROLL_STATE_IDLE) {
                    viewAdapter.notifyDataSetChanged()
                }
            }
        })
    }

    private fun prepareToolTipDialogForShowing() {
        val fragmentManager = activity?.supportFragmentManager
        fragmentManager?.beginTransaction()
            ?.add(TooltipInfoDialog.newInstance(), TooltipInfoDialog.MAP_LEGEND_DIALOG_TAG)
            ?.commitAllowingStateLoss()
        fragmentManager?.executePendingTransactions()
    }

    override fun onLocationChanged(location: Location) {
        mapController?.animateMapCamera(location)
    }

    override fun dayChanged(pos: Int) {
        if (pos == 0 || pos == 1 || pos == 2) {
            mapController?.drawHeatMap(pos)
        }
    }

    companion object {
        const val BOTTOM_SHEET_TAG = "HISTORY_BOTTOM_SHEET_TAG"
        fun newInstance(): HistoryBottomSheetDialog = HistoryBottomSheetDialog()
    }

    override fun onDestroy() {
        requireContext().unregisterReceiver(networkBroadcastReceiver)
        if(!keepOpenedStatus)
            mapsViewModel.setBottomSheetOpenedStatus(false)
        else
            keepOpenedStatus = false
        super.onDestroy()
    }
}