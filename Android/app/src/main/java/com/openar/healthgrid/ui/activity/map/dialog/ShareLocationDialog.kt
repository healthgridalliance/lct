package com.openar.healthgrid.ui.activity.map.dialog

import android.app.Dialog
import android.content.Context
import android.content.DialogInterface
import android.os.Bundle
import android.text.Layout
import android.text.SpannableString
import android.text.style.AlignmentSpan
import android.widget.Button
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.activityViewModels
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.map.viewmodel.MapsViewModel
import com.openar.healthgrid.util.OfflineNotificationUtils

class ShareLocationDialog : DialogFragment() {
    private val viewModel: MapsViewModel by activityViewModels()
    private var onDismissListener: DialogInterface.OnDismissListener? = null
    private var listener: DecisionListener? = null
    private lateinit var id: String

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        id = if (arguments != null) arguments?.getString("id") ?: "" else ""
        val builder: AlertDialog.Builder = AlertDialog.Builder(requireContext(), R.style.SettingsAlertDialogTheme)
        val title = SpannableString(getString(R.string.share_location_dialog_title))
        title.setSpan(AlignmentSpan.Standard(Layout.Alignment.ALIGN_CENTER), 0, title.length, 0)
        builder.setTitle(title)
            .setMessage(R.string.share_location_dialog_message)
            .setPositiveButton(R.string.share_location_dialog_positive, null)
            .setNegativeButton(R.string.share_location_dialog_negative, DialogInterface.OnClickListener { _, _ ->
                listener?.onNegativeTap()
            })
        val dialog = builder.create()
        dialog.setOnShowListener {
            val button: Button = dialog.getButton(AlertDialog.BUTTON_POSITIVE)
            button.setOnClickListener {
                if (OfflineNotificationUtils.verifyAvailableNetwork(requireContext())) {
                    listener?.onPositiveTap(id)
                    dismiss()
                }
            }
        }
        return dialog
    }

    override fun onDestroy() {
        viewModel.setBottomSheetOpenedStatus(false)
        super.onDestroy()
    }

    override fun onDismiss(dialog: DialogInterface) {
        super.onDismiss(dialog)
        onDismissListener?.onDismiss(dialog)
    }

    fun setOnDismissListener(listener: DialogInterface.OnDismissListener?) {
        onDismissListener = listener
    }

    override fun onAttach(context: Context) {
        listener = parentFragment as DecisionListener
        super.onAttach(context)
    }

    override fun onDetach() {
        listener = null
        super.onDetach()
    }

    interface DecisionListener {
        fun onPositiveTap(id: String)
        fun onNegativeTap()

    }

    companion object {
        const val DIALOG_TAG: String = "SHARE_LOCATION_DIALOG"
        fun newInstance(id: String): ShareLocationDialog {
            val dialog = ShareLocationDialog()
            val args = Bundle()
            args.putString("id", id)
            dialog.arguments = args
            return dialog
        }
    }
}