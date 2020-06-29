package com.openar.healthgrid.ui.fragment.exposure

import android.Manifest
import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.lifecycle.Observer
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.exposure.PermissionsViewModel
import com.openar.healthgrid.ui.activity.map.dialog.OpenAppSettingsDialog
import com.openar.healthgrid.util.OfflineNotificationUtils
import com.openar.healthgrid.util.PermissionUtils
import com.openar.healthgrid.util.PreferenceStorage
import kotlinx.android.synthetic.main.fragment_exposure_start.*
import kotlinx.android.synthetic.main.no_connection_alert.*

class ExposureStartFragment : Fragment() {
    private var actionListener: ExposureStartFragmentAction? = null
    private val permissionsViewModel: PermissionsViewModel by activityViewModels()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_exposure_start, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        skip_button.setOnClickListener { actionListener?.skipCheckExposure() }
        next_button.setOnClickListener {
            if(OfflineNotificationUtils.verifyAvailableNetwork(requireContext()))
                actionListener?.checkExposure()
            else
                OfflineNotificationUtils.showSnackBarMessage(requireActivity().top_coordinator, requireContext())
        }
        permissionsViewModel.isLocationSwitchedOn().observe(requireActivity(), Observer { switchedOn ->
            if(next_button != null) {
                next_button.isEnabled = switchedOn
                if (switchedOn)
                    next_button.background = ContextCompat.getDrawable(
                        requireContext(),
                        R.drawable.base_button_box_radius
                    )
                else
                    next_button.background = ContextCompat.getDrawable(
                        requireContext(),
                        R.drawable.inactive_base_button_box_radius
                    )
            }
        })
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        actionListener = activity as ExposureStartFragmentAction
    }

    override fun onStart() {
        super.onStart()
        if(!permissionsViewModel.isWelcomeVisible()) {
            if(PermissionUtils.isPermissionGranted(requireContext(), Manifest.permission.ACCESS_FINE_LOCATION)) {
                permissionsViewModel.setLocationPermissionStatus(true)
            } else {
                showPermissionDialogIfNeeded()
            }
            PermissionUtils.checkGeolocationServicesSwitchedOn(requireContext(), this::geolocationSwitchedOn)
        }
    }

    private fun geolocationSwitchedOn(res: Boolean) = permissionsViewModel.setLocationSwitchedOnStatus(res)

    override fun onDetach() {
        actionListener = null
        super.onDetach()
    }

    private fun showPermissionDialogIfNeeded() {
        if (!PermissionUtils.isPermissionGranted(requireContext(), Manifest.permission.ACCESS_FINE_LOCATION) &&
            !PreferenceStorage.getPropertyBooleanFalse(requireContext(), PreferenceStorage.SETTINGS_DIALOG_VISIBLE)) {
            OpenAppSettingsDialog.newInstance().show(childFragmentManager, OpenAppSettingsDialog.DIALOG_TAG)
        }
    }

    interface ExposureStartFragmentAction {
        fun skipCheckExposure()
        fun checkExposure()
    }

    companion object {
        const val EXPOSURE_START_TAG = "EXPOSURE_START"
        fun newInstance(): ExposureStartFragment = ExposureStartFragment()
    }
}
