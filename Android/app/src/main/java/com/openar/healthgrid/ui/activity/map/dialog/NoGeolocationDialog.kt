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

class NoGeolocationDialog : DialogFragment() {
    private var onDismissListener: DialogInterface.OnDismissListener? = null

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val builder: AlertDialog.Builder = AlertDialog.Builder(requireContext(), R.style.SettingsAlertDialogTheme)
        val title = SpannableString(getString(R.string.attention))
        title.setSpan(AlignmentSpan.Standard(Layout.Alignment.ALIGN_CENTER), 0, title.length, 0)
        builder.setTitle(title)
            .setMessage(R.string.no_geolocation_message)
            .setPositiveButton(R.string.ok_label) { _, _ ->
            }
        return builder.create()
    }

    override fun onDestroy() {
        super.onDestroy()
    }

    override fun onDismiss(dialog: DialogInterface) {
        super.onDismiss(dialog)
        onDismissListener?.onDismiss(dialog)
    }

    fun setOnDismissListener(listener: DialogInterface.OnDismissListener?) {
        onDismissListener = listener
    }

    companion object {
        const val DIALOG_TAG: String = "NO_GEOLOCATION"
        fun newInstance(): NoGeolocationDialog = NoGeolocationDialog()
    }
}