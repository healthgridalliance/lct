package com.openar.healthgrid.ui.activity.map.dialog

import android.app.Dialog
import android.content.DialogInterface
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.activityViewModels
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.map.viewmodel.MapsViewModel
import com.openar.healthgrid.util.OfflineNotificationUtils
import kotlinx.android.synthetic.main.no_connection_alert.*


class DeleteDataDialog private constructor() : DialogFragment() {
    private val viewModel: MapsViewModel by activityViewModels()

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val builder: AlertDialog.Builder = AlertDialog.Builder(requireContext())
        builder.setTitle(R.string.delete_data_title)
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

class OpenAppSettingsDialog private constructor() : DialogFragment() {
    private val viewModel: MapsViewModel by activityViewModels()

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val builder: AlertDialog.Builder = AlertDialog.Builder(requireContext(), R.style.SettingsAlertDialogTheme)
        builder.setTitle(R.string.open_app_settings_title)
            .setMessage(R.string.open_app_settings_message)
            .setPositiveButton(R.string.open_app_settings_positive, DialogInterface.OnClickListener { _, _ ->
                openSettings()
            })
            .setNegativeButton(R.string.cancel_button_label, DialogInterface.OnClickListener { _, _ -> })
        return builder.create()
    }

    private fun openSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        val uri: Uri = Uri.fromParts("package", requireActivity().packageName, null)
        intent.data = uri
        startActivity(intent)
    }

    override fun onDestroy() {
        viewModel.setBottomSheetOpenedStatus(false)
        super.onDestroy()
    }

    companion object {
        const val DIALOG_TAG: String = "OPEN_APP_SETTINGS_DIALOG"
        fun newInstance(): OpenAppSettingsDialog = OpenAppSettingsDialog()
    }
}