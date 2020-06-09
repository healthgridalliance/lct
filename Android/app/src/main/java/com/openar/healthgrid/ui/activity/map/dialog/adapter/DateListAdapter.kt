package com.openar.healthgrid.ui.activity.map.dialog.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.map.dialog.HistoryBottomSheetDialog
import com.openar.healthgrid.ui.activity.map.viewmodel.HistoryViewModel

class DateListAdapter(
    private val context: Context,
    private val viewModel: HistoryViewModel,
    private val dateChangeListener: HistoryBottomSheetDialog
) :
    RecyclerView.Adapter<DateListAdapter.DateViewHolder>() {
    private lateinit var recyclerView: RecyclerView

    override fun onAttachedToRecyclerView(recyclerView: RecyclerView) {
        super.onAttachedToRecyclerView(recyclerView)
        this.recyclerView = recyclerView
    }

    inner class DateViewHolder(val view: View) : RecyclerView.ViewHolder(view) {
        val date = view.findViewById(R.id.date) as TextView
        val weekday = view.findViewById(R.id.weekday) as TextView

        fun makeInactive() {
            view.isEnabled = false
            date.setTextColor(ContextCompat.getColor(context, R.color.inactive_view_color))
            weekday.setTextColor(ContextCompat.getColor(context, R.color.inactive_view_color))
        }

        fun makeActive() {
            view.isEnabled = true
            date.setTextColor(ContextCompat.getColor(context, R.color.day_color))
            weekday.setTextColor(ContextCompat.getColor(context, R.color.weekday_color))
        }

        fun setInFocusState() {
            date.setTextColor(ContextCompat.getColor(context, android.R.color.white))
            weekday.setTextColor(ContextCompat.getColor(context, R.color.weekday_color))
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): DateViewHolder {
        val view =
            LayoutInflater.from(parent.context).inflate(R.layout.date_item, parent, false)
        val holder = DateViewHolder(view)
        view.setOnClickListener {
            recyclerView.post {
                val firstPos =
                    (recyclerView.layoutManager as LinearLayoutManager).findFirstVisibleItemPosition()
                val lastPos =
                    (recyclerView.layoutManager as LinearLayoutManager).findLastVisibleItemPosition()
                recyclerView.smoothScrollToPosition(holder.adapterPosition + (lastPos - firstPos))
            }
        }
        return holder
    }

    override fun onBindViewHolder(holder: DateViewHolder, position: Int) {
        when (getItemViewType(position)) {
            INACTIVE -> holder.makeInactive()
            ACTIVE -> holder.makeActive()
            else -> holder.setInFocusState()
        }
        holder.date.text = viewModel.getHistoryDates().value?.get(position)?.shortDate.toString()
        holder.weekday.text = viewModel.getHistoryDates().value?.get(position)?.weekday
    }

    override fun getItemCount() = viewModel.getHistoryDates().value?.size ?: 0

    override fun getItemViewType(position: Int): Int {
        val pos = (recyclerView.layoutManager as LinearLayoutManager).findFirstVisibleItemPosition()
        return when {
            pos == -1 -> {
                dateChangeListener.dayChanged(position)
                IN_FOCUS
            }
            position < (viewModel.getActiveDaysNumber().value ?: 0) -> ACTIVE
            else -> INACTIVE
        }
    }

    companion object {
        private const val IN_FOCUS = 3
        private const val ACTIVE = 2
        private const val INACTIVE = 1
    }
}
