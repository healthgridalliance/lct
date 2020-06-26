package com.openar.healthgrid.ui.activity.map.dialog.infected.fragments

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.openar.healthgrid.R
import kotlinx.android.synthetic.main.bottom_sheet_toolbar.*
import kotlinx.android.synthetic.main.modal_bottom_sheet_confirm_status_fragment.*

class InfectedStatusStartFragment : BottomSheetDialogFragment() {
    private var actionListener: InfectedStatusStartAction? = null

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(
            R.layout.modal_bottom_sheet_confirm_status_fragment,
            container,
            false
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        exit.setOnClickListener { actionListener?.onExitButtonTapped() }
        action_button.setOnClickListener { actionListener?.openShareDiagnosisScreen() }
        leading.setOnClickListener{ actionListener?.returnToMainScreen() }
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        actionListener = parentFragment as InfectedStatusStartAction
    }

    override fun onDetach() {
        actionListener = null
        super.onDetach()
    }

    interface InfectedStatusStartAction {
        fun openShareDiagnosisScreen()
        fun returnToMainScreen()
        fun onExitButtonTapped()
    }

    companion object {
        const val INFECTED_STATUS_START = "INFECTED_STATUS_START"
        fun newInstance(): InfectedStatusStartFragment = InfectedStatusStartFragment()
    }
}