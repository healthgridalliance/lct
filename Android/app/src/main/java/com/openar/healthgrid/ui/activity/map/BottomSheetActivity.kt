package com.openar.healthgrid.ui.activity.map

import android.os.Bundle
import android.widget.Button
import androidx.lifecycle.Observer
import com.google.android.gms.maps.OnMapReadyCallback
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.map.dialog.ConfigurationBottomSheetDialog
import com.openar.healthgrid.ui.activity.map.dialog.ExposureDialog
import com.openar.healthgrid.ui.activity.map.dialog.StatusBottomSheetDialog
import com.openar.healthgrid.util.OfflineNotificationUtils
import kotlinx.android.synthetic.main.no_connection_alert.*

abstract class BottomSheetActivity : BaseLoadActivity(), OnMapReadyCallback {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        findViewById<Button>(R.id.status_button).setOnClickListener {
            val bottomSheet = StatusBottomSheetDialog.newInstance()
            bottomSheet.show(supportFragmentManager, StatusBottomSheetDialog.BOTTOM_SHEET_TAG)
            OfflineNotificationUtils.removeSnackBarMessage(top_coordinator, this)
            mapsViewModel.setBottomSheetOpenedStatus(true)
        }

        findViewById<Button>(R.id.configuration_button).setOnClickListener {
            val bottomSheet = ConfigurationBottomSheetDialog.newInstance()
            bottomSheet.show(supportFragmentManager, ConfigurationBottomSheetDialog.BOTTOM_SHEET_TAG)
            OfflineNotificationUtils.removeSnackBarMessage(top_coordinator, this)
            mapsViewModel.setBottomSheetOpenedStatus(true)
        }

        setObservers()
    }

    private fun setObservers() {
        mapsViewModel.exposureInfo.observe(this, Observer { exposures ->
            if(exposures != null) {
                val dialog = ExposureDialog.newInstance(exposures.keys.toList())
                if (!dialog.isVisible) {
                    val fragmentManager = supportFragmentManager
                    fragmentManager.beginTransaction().add(dialog, ExposureDialog.DIALOG_TAG)
                        .commitAllowingStateLoss()
                    fragmentManager.executePendingTransactions()
                }
            }
        })
    }
}