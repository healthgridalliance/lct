package com.openar.healthgrid.ui.activity.map.dialog

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.RadioGroup
import android.widget.TextView
import androidx.fragment.app.activityViewModels
import androidx.lifecycle.Observer
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.openar.healthgrid.Constants
import com.openar.healthgrid.HealthGridApplication
import com.openar.healthgrid.R
import com.openar.healthgrid.service.BackgroundLocationWork
import com.openar.healthgrid.service.StartJobAfterDelay
import com.openar.healthgrid.ui.activity.map.viewmodel.MapsViewModel
import com.openar.healthgrid.util.BroadcastUtils
import com.openar.healthgrid.util.PermissionUtils
import com.openar.healthgrid.util.PreferenceStorage
import com.openar.healthgrid.util.WorkUtils
import kotlinx.android.synthetic.main.modal_bottom_sheet_configuration.*


class ConfigurationBottomSheetDialog private constructor(): BaseBottomSheetDialog() {
    private lateinit var title: TextView
    private lateinit var radioGroup: RadioGroup
    private val viewModel: MapsViewModel by activityViewModels()
    private lateinit var localBroadcastManager: LocalBroadcastManager
    private lateinit var broadcastReceiver: TrackingStatusBroadcastReceiver
    private var keepOpenedStatus = false

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view: View = inflater.inflate(R.layout.modal_bottom_sheet_configuration, container, false)
        initVariables(view)
        setVariables()
        setListeners()
        super.onCreateView(view)
        return view
    }

    private fun initVariables(view: View) {
        localBroadcastManager = LocalBroadcastManager.getInstance(requireContext())
        broadcastReceiver = TrackingStatusBroadcastReceiver()
        title = view.findViewById(R.id.header_title)
        radioGroup = view.findViewById(R.id.configuration_radio_group)
    }

    private fun setVariables() {
        viewModel.trackingStatusId.observe(viewLifecycleOwner, Observer { id ->
            when(id) {
                Constants.ACTIVE_TRACKING_STATUS -> radioGroup.check(R.id.radio_turn_on)
                Constants.PARTIALLY_INACTIVE_TRACKING_STATUS -> if(PreferenceStorage.getPropertyBooleanFalse(HealthGridApplication.getApplicationContext(), PreferenceStorage.NEED_ACTIVATE_TRACKING)) {
                    PreferenceStorage.addPropertyBoolean(HealthGridApplication.getApplicationContext(), PreferenceStorage.NEED_ACTIVATE_TRACKING, false)
                    radioGroup.check(R.id.radio_turn_on)
                } else {
                    radioGroup.check(R.id.radio_turn_off)
                }
                Constants.INACTIVE_TRACKING_STATUS -> radioGroup.check(R.id.radio_turn_off_forever)

            }
        })
        title.text = getString(R.string.configuration)
    }

    private fun setListeners() {
        radioGroup.setOnCheckedChangeListener { _, checkedId ->
            when (checkedId) {
                R.id.radio_turn_on -> context?.let {
                    if (!PermissionUtils.isPermissionGranted(requireContext(), Manifest.permission.ACCESS_FINE_LOCATION)) {
                        dismiss()
                        keepOpenedStatus = true
                        OpenAppSettingsDialog.newInstance().show(parentFragmentManager, OpenAppSettingsDialog.DIALOG_TAG)
                    } else {
                        viewModel.setTrackingStatusId(Constants.ACTIVE_TRACKING_STATUS)
                        WorkUtils.startBackgroundJob(requireContext())
                    }
                }
                R.id.radio_turn_off -> context?.let {
                    viewModel.setTrackingStatusId(Constants.PARTIALLY_INACTIVE_TRACKING_STATUS)
                    PreferenceStorage.addPropertyBoolean(requireContext(), PreferenceStorage.TRACKING_STARTED_FLAG, false)
                    WorkUtils.stopUniqueJob(requireContext(), BackgroundLocationWork.JOB_ID)
                    BroadcastUtils.sendBroadcast(requireContext(), STOP_LOCATION)
                    WorkUtils.scheduleTurnOnTrackingAfterTime(requireContext(), Constants.TURN_OFF_TRACKING_MINUTES)
                }
                R.id.radio_turn_off_forever -> context?.let {
                    viewModel.setTrackingStatusId(Constants.INACTIVE_TRACKING_STATUS)
                    PreferenceStorage.addPropertyBoolean(requireContext(), PreferenceStorage.TRACKING_STARTED_FLAG, false)
                    WorkUtils.stopUniqueJob(requireContext(), BackgroundLocationWork.JOB_ID)
                    BroadcastUtils.sendBroadcast(requireContext(), STOP_LOCATION)
                }
            }
        }
        localBroadcastManager.registerReceiver(broadcastReceiver, IntentFilter(StartJobAfterDelay.BROADCAST_ACTION))
    }



    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        bottom_sheet_policy.setOnClickListener {
            val bottomSheet = PrivacyPolicyBottomSheetDialog.newInstance()
            activity?.supportFragmentManager?.let { manager ->
                bottomSheet.show(manager, PrivacyPolicyBottomSheetDialog.BOTTOM_SHEET_TAG)
                dismiss()
                keepOpenedStatus = true
            }
        }

        bottom_sheet_delete_all.setOnClickListener {
            dismiss()
            activity?.supportFragmentManager?.let { it1 ->
                DeleteDataDialog.newInstance().show(it1, DeleteDataDialog.DIALOG_TAG)
            }
        }

        health_history.setOnClickListener {
            val bottomSheet = HistoryBottomSheetDialog.newInstance()
            bottomSheet.isCancelable = false
            activity?.supportFragmentManager?.let { manager ->
                bottomSheet.show(manager, HistoryBottomSheetDialog.BOTTOM_SHEET_TAG)
                dismiss()
                keepOpenedStatus = true
            }
        }
    }

    inner class TrackingStatusBroadcastReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if(intent.action == StartJobAfterDelay.BROADCAST_ACTION) {
                val curTrackingStatus = intent.extras?.getInt(StartJobAfterDelay.TRACKING_MODE)
                if (curTrackingStatus != null) {
                    viewModel.setTrackingStatusId(curTrackingStatus)
                }
            }
        }
    }

    override fun onDestroy() {
        localBroadcastManager.unregisterReceiver(broadcastReceiver)
        if(!keepOpenedStatus) {
            viewModel.setBottomSheetOpenedStatus(false)
        } else {
            keepOpenedStatus = false
        }
        super.onDestroy()
    }

    companion object {
        const val STOP_LOCATION = "stop_location"
        const val BOTTOM_SHEET_TAG = "CONFIGURATION_BOTTOM_SHEET_TAG"
        fun newInstance(): ConfigurationBottomSheetDialog = ConfigurationBottomSheetDialog()
    }
}