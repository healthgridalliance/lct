package com.openar.healthgrid.ui.activity.map.dialog

import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.*
import android.widget.TextView
import androidx.fragment.app.DialogFragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.openar.healthgrid.R
import kotlinx.android.synthetic.main.exposure_dialog.*


class ExposureDialog private constructor(private val dates: List<String>): DialogFragment() {
    private lateinit var recyclerView: RecyclerView
    private lateinit var viewAdapter: RecyclerView.Adapter<*>
    private lateinit var viewManager: RecyclerView.LayoutManager

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(R.layout.exposure_dialog, container)
        constructDialog(view)
        initDialog()
        return view
    }

    private fun constructDialog(view: View) {
        viewManager = LinearLayoutManager(context)
        context?.let { viewAdapter = ExposureListAdapter(dates) }
        recyclerView = view.findViewById(R.id.exposure_recycler_view)
        recyclerView.apply {
            canScrollVertically(0)
            setHasFixedSize(true)
            layoutManager = viewManager
            adapter = viewAdapter
        }
    }

    private fun initDialog() {
        dialog?.requestWindowFeature(Window.FEATURE_NO_TITLE)
        dialog?.setCancelable(true)
        dialog?.setContentView(R.layout.exposure_dialog)
        val dialogWindow = dialog?.window
        dialogWindow?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        val lp = WindowManager.LayoutParams()
        lp.copyFrom(dialogWindow?.attributes)
        val density = requireActivity().resources.displayMetrics.density
        lp.height = ((if(dates.isEmpty()) 200 else 450) * density).toInt()
        dialogWindow?.attributes = lp
    }

    override fun onStart() {
        super.onStart()
        message.text = if(dates.isNotEmpty()) getText(R.string.positive_push_dialog_message) else getText(R.string.negative_push_dialog_message)
        ok_button.setOnClickListener { dialog?.dismiss() }
        if(dates.isEmpty())
            exposure_recycler_view.visibility = View.GONE
    }

    override fun onDestroyView() {
        dialog?.dismiss()
        super.onDestroyView()
    }

    class ExposureListAdapter(private val dates: List<String>) :
        RecyclerView.Adapter<ExposureListAdapter.LegendViewHolder>() {

        class LegendViewHolder(view: View) : RecyclerView.ViewHolder(view) {
            val date = view.findViewById(R.id.exposure_date) as TextView
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): LegendViewHolder {
            val view = LayoutInflater.from(parent.context).inflate(R.layout.exposure_item, parent, false)
            return LegendViewHolder(view)
        }

        override fun onBindViewHolder(holder: LegendViewHolder, position: Int) {
            holder.date.text = dates[position]
        }

        override fun getItemCount() = dates.size
    }

    companion object {
        const val DIALOG_TAG = "exposure_dialog"

        fun newInstance(dates: List<String>): ExposureDialog = ExposureDialog(dates)
    }
}