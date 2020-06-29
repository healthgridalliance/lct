package com.openar.healthgrid.ui.activity.map

import com.google.android.gms.maps.OnMapReadyCallback
import com.openar.healthgrid.ui.activity.map.dialog.LegendInfoDialog
import kotlinx.android.synthetic.main.map_action_buttons.*

abstract class MapsManageButtonsActivity : BottomSheetActivity(), OnMapReadyCallback {
    private var infoDialog: LegendInfoDialog? = null

    override fun onStart() {
        super.onStart()
        legend_info.setOnClickListener { prepareLegendInfoDialogForShowing() }
    }

    private fun prepareLegendInfoDialogForShowing() {
        if (!isFinishing) {
            if (infoDialog == null) infoDialog =
                LegendInfoDialog.newInstance()
            infoDialog?.let {
                if (!it.isVisible) {
                    val fragmentManager =
                        supportFragmentManager
                    fragmentManager.beginTransaction()
                        .add(it, LegendInfoDialog.MAP_LEGEND_DIALOG_TAG)
                        .commitAllowingStateLoss()
                    fragmentManager.executePendingTransactions()
                }
            }
        }
    }
}