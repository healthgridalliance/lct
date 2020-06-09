package com.openar.healthgrid.ui.activity.map.dialog

import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.*
import androidx.fragment.app.DialogFragment
import com.openar.healthgrid.R


class TooltipInfoDialog private constructor(): DialogFragment() {

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(R.layout.tooltip_info_dialog, container)
        initDialog()
        return view
    }

    private fun initDialog() {
        dialog?.requestWindowFeature(Window.FEATURE_NO_TITLE)
        dialog?.setCancelable(true)
        dialog?.setContentView(R.layout.tooltip_info_dialog)
        val dialogWindow = dialog?.window
        dialogWindow?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        val density = requireActivity().resources.displayMetrics.density
        val wlp = dialogWindow!!.attributes
        wlp.gravity = Gravity.BOTTOM or Gravity.END
        wlp.width = WindowManager.LayoutParams.WRAP_CONTENT
        val bottomPaddingDp =
            requireActivity().resources.getDimension(R.dimen.date_picker_margin_bottom) +
                    requireActivity().resources.getDimension(R.dimen.date_picker_max_height) + 10 * density
        wlp.y =  bottomPaddingDp.toInt()
        val endPaddingDp = requireActivity().resources.getDimension(R.dimen.date_picker_margin_end)
        wlp.x =  endPaddingDp.toInt()
        dialogWindow.attributes = wlp
    }

    companion object {
        const val MAP_LEGEND_DIALOG_TAG: String = "MAP_LEGEND_DIALOG_TAG"
        fun newInstance(): TooltipInfoDialog = TooltipInfoDialog()
    }
}