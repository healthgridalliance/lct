package com.openar.healthgrid.ui.activity.map.dialog

import android.content.Context
import android.content.DialogInterface
import android.content.res.TypedArray
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.DialogFragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.openar.healthgrid.R
import com.openar.healthgrid.util.PreferenceStorage
import com.openar.healthgrid.util.StringFormatUtils
import kotlinx.android.synthetic.main.dialog_header.*

class LegendInfoDialog : DialogFragment() {
    private var onDismissListener: DialogInterface.OnDismissListener? = null
    private lateinit var recyclerView: RecyclerView
    private lateinit var viewAdapter: RecyclerView.Adapter<*>
    private lateinit var viewManager: RecyclerView.LayoutManager

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(R.layout.map_legend_dialog, container)
        constructDialog(view)
        initDialog()
        return view
    }

    private fun constructDialog(view: View) {
        viewManager = LinearLayoutManager(context)
        context?.let { viewAdapter = LegendListAdapter(it) }
        recyclerView = view.findViewById(R.id.legend_recycler_view)
        recyclerView.apply {
            canScrollVertically(0)
            setHasFixedSize(true)
            layoutManager = viewManager
            adapter = viewAdapter
        }
    }

    override fun onDismiss(dialog: DialogInterface) {
        super.onDismiss(dialog)
        if (onDismissListener != null) {
            onDismissListener?.onDismiss(dialog)
        }
    }

    private fun initDialog() {
        dialog?.requestWindowFeature(Window.FEATURE_NO_TITLE)
        dialog?.setCancelable(true)
        dialog?.setContentView(R.layout.map_legend_dialog)
        val dialogWindow = dialog?.window
        dialogWindow?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
    }

    override fun onStart() {
        super.onStart()
        legend_exit.setOnClickListener { dialog?.dismiss() }
    }

    override fun onDestroyView() {
        dialog?.dismiss()
        super.onDestroyView()
    }

    class LegendListAdapter(private val context: Context) :
        RecyclerView.Adapter<LegendListAdapter.LegendViewHolder>() {
        private var textArray: TypedArray = context.resources.obtainTypedArray(R.array.legend_text_lines)
        private var iconArray: TypedArray = context.resources.obtainTypedArray(R.array.legend_icons)
        private var iconColorArray: TypedArray = context.resources.obtainTypedArray(R.array.legend_icon_colors)
        private var legendColors = listOf(
            PreferenceStorage.getPropertyString(context, PreferenceStorage.LEGEND_MAX_COLOR),
            PreferenceStorage.getPropertyString(context, PreferenceStorage.LEGEND_MIN_COLOR)
        )

        class LegendViewHolder(view: View) : RecyclerView.ViewHolder(view) {
            val icon = view.findViewById(R.id.legend_item_icon) as ImageView
            val text = view.findViewById(R.id.legend_item_text) as TextView
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): LegendViewHolder {
            val view =
                LayoutInflater.from(parent.context).inflate(R.layout.legend_item, parent, false)
            return LegendViewHolder(view)
        }

        override fun onBindViewHolder(holder: LegendViewHolder, position: Int) {
            holder.text.text = textArray.getText(position)
            holder.icon.setImageDrawable(iconArray.getDrawable(position))
            val isValidColor = StringFormatUtils.isHexFormat(legendColors[position])
            val color =
                if (isValidColor)
                    Color.parseColor(legendColors[position])
                else
                    iconColorArray.getColor(position, ContextCompat.getColor(context, R.color.max_color))
            holder.icon.setColorFilter(color)
        }

        override fun getItemCount() = textArray.length()
    }

    companion object {
        const val MAP_LEGEND_DIALOG_TAG: String = "MAP_LEGEND_DIALOG_TAG"
        fun newInstance(): LegendInfoDialog = LegendInfoDialog()
    }
}