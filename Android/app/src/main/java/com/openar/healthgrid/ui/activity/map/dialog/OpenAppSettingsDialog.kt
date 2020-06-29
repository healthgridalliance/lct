package com.openar.healthgrid.ui.activity.map.dialog

import android.app.Dialog
import android.content.DialogInterface
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.text.Layout
import android.text.SpannableString
import android.text.style.AlignmentSpan
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.activityViewModels
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.exposure.PermissionsViewModel
import com.openar.healthgrid.ui.activity.map.viewmodel.MapsViewModel
import com.openar.healthgrid.util.PreferenceStorage

class OpenAppSettingsDialog : DialogFragment() {
    private val viewModel: MapsViewModel by activityViewModels()
    private val permissionsViewModel: PermissionsViewModel by activityViewModels()
    private var onDismissListener: DialogInterface.OnDismissListener? = null

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val builder: AlertDialog.Builder = AlertDialog.Builder(requireContext(), R.style.SettingsAlertDialogTheme)
        val title = SpannableString(getString(R.string.open_app_settings_title))
        title.setSpan(AlignmentSpan.Standard(Layout.Alignment.ALIGN_CENTER), 0, title.length, 0)
        builder.setTitle(title)
            .setMessage(R.string.open_app_settings_message)
            .setPositiveButton(R.string.open_app_settings_positive) { _, _ ->
                PreferenceStorage.addPropertyBoolean(requireContext(), PreferenceStorage.SETTINGS_DIALOG_VISIBLE, false)
                permissionsViewModel.settingsOpened = true
                openSettings()
            }
            .setNegativeButton(R.string.cancel_button_label) { _, _ ->
                PreferenceStorage.addPropertyBoolean(requireContext(), PreferenceStorage.SETTINGS_DIALOG_VISIBLE, false)
            }
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

    override fun onDismiss(dialog: DialogInterface) {
        super.onDismiss(dialog)
        if(!permissionsViewModel.settingsOpened)
            onDismissListener?.onDismiss(dialog)
    }

    fun setOnDismissListener(listener: DialogInterface.OnDismissListener?) {
        onDismissListener = listener
    }

    companion object {
        const val DIALOG_TAG: String = "OPEN_APP_SETTINGS_DIALOG"
        fun newInstance(): OpenAppSettingsDialog = OpenAppSettingsDialog()
    }
}