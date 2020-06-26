package com.openar.healthgrid.ui.fragment.exposure

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.openar.healthgrid.R
import com.openar.healthgrid.repository.HeatZonesRepository
import com.openar.healthgrid.ui.activity.exposure.HeatZonesViewModel
import kotlinx.android.synthetic.main.fragment_exposure_details.*

class ExposureDetailsFragment : Fragment() {
    private var actionListener: ExposureDetailsFragmentAction? = null
    private lateinit var recyclerView: RecyclerView
    private lateinit var viewAdapter: RecyclerView.Adapter<*>
    private lateinit var viewManager: RecyclerView.LayoutManager
    private val heatZonesViewModel: HeatZonesViewModel by activityViewModels()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(R.layout.fragment_exposure_details, container, false)
        constructRecyclerView(view)
        return view
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        next_button.setOnClickListener { actionListener?.navigateToMap() }
        leading.setOnClickListener { actionListener?.backToResult() }
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        actionListener = activity as ExposureDetailsFragmentAction
    }

    override fun onDetach() {
        actionListener = null
        super.onDetach()
    }

    private fun constructRecyclerView(view: View) {
        HeatZonesRepository.instance.exposureInfo?.keys?.toList()?.let {
            viewManager = LinearLayoutManager(context)
            viewAdapter = ExposureListAdapter(it)
            recyclerView = view.findViewById(R.id.exposure_details_recycler_view)
            val divider = DividerItemDecoration(context, DividerItemDecoration.VERTICAL)
            ContextCompat.getDrawable(requireContext(), R.drawable.recyclerview_divider)?.let { div ->
                    divider.setDrawable(div)
                }
            recyclerView.apply {
                canScrollVertically(0)
                setHasFixedSize(true)
                layoutManager = viewManager
                adapter = viewAdapter
                addItemDecoration(divider)
            }
        }
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

    interface ExposureDetailsFragmentAction {
        fun navigateToMap()
        fun backToResult()
    }

    companion object {
        const val EXPOSURE_DETAILS_TAG = "EXPOSURE_DETAILS"
        fun newInstance(): ExposureDetailsFragment = ExposureDetailsFragment()
    }
}
