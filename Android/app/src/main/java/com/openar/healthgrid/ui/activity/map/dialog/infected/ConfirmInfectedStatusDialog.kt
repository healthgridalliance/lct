package com.openar.healthgrid.ui.activity.map.dialog.infected

import android.os.Bundle
import android.view.KeyEvent
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.map.dialog.bottomsheet.NetworkBottomSheet
import com.openar.healthgrid.ui.activity.map.dialog.ShareLocationDialog
import com.openar.healthgrid.ui.activity.map.dialog.infected.fragments.InfectedStatusDoneFragment
import com.openar.healthgrid.ui.activity.map.dialog.infected.fragments.InfectedStatusStartFragment
import com.openar.healthgrid.ui.activity.map.dialog.infected.fragments.InfectedStatusVerifyFragment
import com.openar.healthgrid.util.PreferenceStorage

class ConfirmInfectedStatusDialog : NetworkBottomSheet(),
    InfectedStatusStartFragment.InfectedStatusStartAction,
    InfectedStatusVerifyFragment.InfectedStatusVerifyAction,
    InfectedStatusDoneFragment.InfectedStatusDoneAction,
    ShareLocationDialog.DecisionListener {

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view: View =
            inflater.inflate(R.layout.modal_bottom_sheet_confirm_status, container, false)
        onCreateView(view)
        dialog?.setOnKeyListener { _, keyCode, event ->
            if (event.action == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_BACK) {
                if (childFragmentManager.backStackEntryCount != 2)
                    dismiss()
                else
                    childFragmentManager.popBackStack()
                true
            } else false
        }
        childFragmentManager.beginTransaction()
            .replace(
                R.id.infected_status_fragment,
                InfectedStatusStartFragment.newInstance(),
                InfectedStatusStartFragment.INFECTED_STATUS_START
            )
            .addToBackStack(InfectedStatusStartFragment.INFECTED_STATUS_START)
            .commit()
        return view
    }

    override fun openShareDiagnosisScreen() {
        childFragmentManager.beginTransaction()
            .replace(
                R.id.infected_status_fragment,
                InfectedStatusVerifyFragment.newInstance(),
                InfectedStatusVerifyFragment.INFECTED_STATUS_VERIFY
            )
            .addToBackStack(InfectedStatusVerifyFragment.INFECTED_STATUS_VERIFY)
            .commit()
    }

    override fun onExitButtonTapped() = dismiss()

    override fun openPrevScreen() = childFragmentManager.popBackStack()

    override fun openResultScreen() {
        childFragmentManager.beginTransaction()
            .replace(
                R.id.infected_status_fragment,
                InfectedStatusDoneFragment.newInstance(),
                InfectedStatusDoneFragment.INFECTED_STATUS_DONE
            )
            .addToBackStack(InfectedStatusDoneFragment.INFECTED_STATUS_DONE)
            .commit()
    }

    override fun returnToMainScreen() = dismiss()

    override fun onPositiveTap(id: String) {
        PreferenceStorage.addPropertyString(requireContext(), PreferenceStorage.TEST_ID, id)
        mapsViewModel.sendLocationList(id)
        openResultScreen()
    }

    override fun onNegativeTap() {
        onExitButtonTapped()
    }

    companion object {
        const val CONFIRM_STATUS_TAG = "CONFIRM_STATUS"
        fun newInstance(): ConfirmInfectedStatusDialog = ConfirmInfectedStatusDialog()
    }
}