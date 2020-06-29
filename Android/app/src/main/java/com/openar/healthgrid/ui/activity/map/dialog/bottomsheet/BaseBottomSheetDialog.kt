package com.openar.healthgrid.ui.activity.map.dialog.bottomsheet

import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Build
import android.os.Bundle
import android.view.View
import androidx.coordinatorlayout.widget.CoordinatorLayout
import androidx.core.content.ContextCompat
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.openar.healthgrid.R
import kotlinx.android.synthetic.main.dialog_header.*

open class BaseBottomSheetDialog : BottomSheetDialogFragment() {

    fun onCreateView(view: View, isHideable: Boolean = true) {
        view.post {
            val parent: View = view.parent as View
            val params: CoordinatorLayout.LayoutParams = parent.layoutParams as (CoordinatorLayout.LayoutParams)
            val behavior: CoordinatorLayout.Behavior<View> = params.behavior as BottomSheetBehavior
            val bottomSheetBehavior: BottomSheetBehavior<View> = behavior as BottomSheetBehavior
            bottomSheetBehavior.peekHeight = view.measuredHeight
            bottomSheetBehavior.isHideable = isHideable
        }
        initDialog()
    }

    private fun initDialog() {
        val dialogWindow = dialog?.window
        dialogWindow?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            context?.let {
                dialogWindow?.navigationBarColor = ContextCompat.getColor(it, R.color.colorPrimary)
            }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        if(legend_exit != null)
            legend_exit.setOnClickListener { dialog?.dismiss() }
    }
}