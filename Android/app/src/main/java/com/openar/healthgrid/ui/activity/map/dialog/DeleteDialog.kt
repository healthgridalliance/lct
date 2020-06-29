package com.openar.healthgrid.ui.activity.map.dialog

import android.app.Dialog
import android.content.DialogInterface
import android.os.Bundle
import android.text.Layout
import android.text.SpannableString
import android.text.style.AlignmentSpan
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.activityViewModels
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.map.viewmodel.MapsViewModel
import com.openar.healthgrid.util.OfflineNotificationUtils
import kotlinx.android.synthetic.main.no_connection_alert.*

class DeleteDataDialog : DialogFragment() {
    private val viewModel: MapsViewModel by activityViewModels()

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val builder: AlertDialog.Builder = AlertDialog.Builder(requireContext())
        val title = SpannableString(getString(R.string.delete_data_title))
        title.setSpan(AlignmentSpan.Standard(Layout.Alignment.ALIGN_CENTER), 0, title.length, 0)
        builder.setTitle(title)
            .setMessage(R.string.delete_data_message)
            .setPositiveButton(R.string.delete_button_label, DialogInterface.OnClickListener { _, _ ->
                if (OfflineNotificationUtils.verifyAvailableNetwork(requireContext())) {
                    viewModel.deleteButtonTapped()
                } else {
                    dismiss()
                    OfflineNotificationUtils.showSnackBarMessage(requireActivity().top_coordinator, requireContext())
                }
            })
            .setNegativeButton(R.string.cancel_button_label) { _, _ -> }
        return builder.create()
    }

    companion object {
        const val DIALOG_TAG: String = "DELETE_TRACKING_DATA_DIALOG"
        fun newInstance(): DeleteDataDialog = DeleteDataDialog()
    }
}