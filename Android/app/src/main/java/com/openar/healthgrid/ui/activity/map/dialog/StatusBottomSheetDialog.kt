package com.openar.healthgrid.ui.activity.map.dialog

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.RadioGroup
import android.widget.TextView
import androidx.fragment.app.activityViewModels
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.map.viewmodel.MapsViewModel
import com.openar.healthgrid.util.OfflineNotificationUtils
import com.openar.healthgrid.util.PreferenceStorage
import kotlinx.android.synthetic.main.modal_bottom_sheet_status.*
import kotlinx.android.synthetic.main.no_connection_alert.*

class StatusBottomSheetDialog private constructor(): BaseBottomSheetDialog() {
    private val viewModel: MapsViewModel by activityViewModels()
    private lateinit var title: TextView
    private lateinit var radioGroup: RadioGroup

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view: View = inflater.inflate(R.layout.modal_bottom_sheet_status, container, false)
        initVariables(view)
        setVariables()
        setListeners()
        super.onCreateView(view)
        return view
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        check_exposure.setOnClickListener {
            dismiss()
            if(OfflineNotificationUtils.verifyAvailableNetwork(requireContext())) {
                viewModel.onExposureButtonTap()
            } else {
                OfflineNotificationUtils.showSnackBarMessage(requireActivity().top_coordinator, requireContext())
            }
        }
    }

    private fun initVariables(view: View) {
        title = view.findViewById(R.id.header_title)
        radioGroup = view.findViewById(R.id.radio_group_container)
    }

    private fun setVariables() {
        when(context?.let { PreferenceStorage.getPropertyInt(it, PreferenceStorage.HEALTH_STATUS_VALUE) } ?: 0) {
            R.id.radio_healthy -> radioGroup.check(R.id.radio_healthy)
            R.id.radio_not_well -> radioGroup.check(R.id.radio_not_well)
            R.id.radio_infected -> radioGroup.check(R.id.radio_infected)
        }
        title.text = getString(R.string.my_status)
    }

    private fun setListeners() {
        radioGroup.setOnCheckedChangeListener { _, checkedId ->
            if(OfflineNotificationUtils.verifyAvailableNetwork(requireContext())) {
                when (checkedId) {
                    R.id.radio_healthy -> context?.let {
                        PreferenceStorage.addPropertyInt(
                            it,
                            PreferenceStorage.HEALTH_STATUS_VALUE,
                            R.id.radio_healthy
                        )
                        viewModel.onInfectedStatusChanged(false)
                    }
                    R.id.radio_not_well -> context?.let {
                        PreferenceStorage.addPropertyInt(
                            it,
                            PreferenceStorage.HEALTH_STATUS_VALUE,
                            R.id.radio_not_well
                        )
                        viewModel.onInfectedStatusChanged(false)
                    }
                    R.id.radio_infected -> context?.let {
                        PreferenceStorage.addPropertyInt(
                            it,
                            PreferenceStorage.HEALTH_STATUS_VALUE,
                            R.id.radio_infected
                        )
                        viewModel.onInfectedStatusChanged(true)
                    }
                }
            } else {
                dismiss()
                OfflineNotificationUtils.showSnackBarMessage(requireActivity().top_coordinator, requireContext())
            }
        }
    }

    override fun onDestroy() {
        viewModel.setBottomSheetOpenedStatus(false)
        super.onDestroy()
    }

    companion object {
        const val BOTTOM_SHEET_TAG = "STATUS_BOTTOM_SHEET_TAG"
        fun newInstance(): StatusBottomSheetDialog = StatusBottomSheetDialog()
    }
}