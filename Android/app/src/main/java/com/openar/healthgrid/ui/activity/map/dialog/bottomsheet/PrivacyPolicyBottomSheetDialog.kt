package com.openar.healthgrid.ui.activity.map.dialog.bottomsheet

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import androidx.fragment.app.activityViewModels
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.map.viewmodel.MapsViewModel
import kotlinx.android.synthetic.main.dialog_header.*
import kotlinx.android.synthetic.main.modal_bottom_sheet_privacy.*

class PrivacyPolicyBottomSheetDialog : BaseBottomSheetDialog() {
    private val viewModel: MapsViewModel by activityViewModels()
    private var keepOpenedStatus = false

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view: View = inflater.inflate(R.layout.modal_bottom_sheet_privacy, container, false)
        val webView = view.findViewById<WebView>(R.id.bottom_sheet_privacy_web_view)
        webView.loadUrl("file:///android_asset/privacy_policy_test_short.html")
        onCreateView(view)
        return view
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        header_title.text = getString(R.string.privacy_policy_bottom_sheet)
        legend_exit.setOnClickListener {
            dismiss()
            keepOpenedStatus = true
            viewModel.loadTrackingStatusValue(requireContext())
            val bottomSheet = ConfigurationBottomSheetDialog.newInstance()
            activity?.supportFragmentManager?.let {
                bottomSheet.show(it, ConfigurationBottomSheetDialog.BOTTOM_SHEET_TAG)
            }
        }
        cancel_button.setOnClickListener { dismiss() }
    }

    override fun onDestroy() {
        if(!keepOpenedStatus)
            viewModel.setBottomSheetOpenedStatus(false)
        else
            keepOpenedStatus = false
        super.onDestroy()
    }

    companion object {
        const val BOTTOM_SHEET_TAG = "PRIVACY_POLICY_BOTTOM_SHEET_TAG"
        fun newInstance(): PrivacyPolicyBottomSheetDialog =
            PrivacyPolicyBottomSheetDialog()
    }
}