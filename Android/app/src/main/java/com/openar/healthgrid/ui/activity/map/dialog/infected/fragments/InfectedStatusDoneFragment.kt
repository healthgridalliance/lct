package com.openar.healthgrid.ui.activity.map.dialog.infected.fragments

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.openar.healthgrid.R
import kotlinx.android.synthetic.main.bottom_sheet_toolbar.*
import kotlinx.android.synthetic.main.confirm_status_info_box.*
import kotlinx.android.synthetic.main.modal_bottom_sheet_confirm_status_fragment.*

class InfectedStatusDoneFragment : BottomSheetDialogFragment() {
    private var actionListener: InfectedStatusDoneAction? = null

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.modal_bottom_sheet_confirm_status_fragment, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        background_logo.visibility = View.VISIBLE
        tooltip.visibility = View.GONE
        toolbar.visibility = View.GONE
        header_title.text = getString(R.string.confirm_status_done_header)
        message.text = getString(R.string.confirm_status_done_message)
        action_button.text = getString(R.string.confirm_status_done_button_text)
        action_button.setOnClickListener { actionListener?.returnToMainScreen() }
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        actionListener = parentFragment as InfectedStatusDoneAction
    }

    override fun onDetach() {
        actionListener = null
        super.onDetach()
    }

    interface InfectedStatusDoneAction {
        fun returnToMainScreen()
    }

    companion object {
        const val INFECTED_STATUS_DONE = "INFECTED_STATUS_DONE"
        fun newInstance(): InfectedStatusDoneFragment = InfectedStatusDoneFragment()
    }
}