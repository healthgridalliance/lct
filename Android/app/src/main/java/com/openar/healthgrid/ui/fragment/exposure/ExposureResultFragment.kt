package com.openar.healthgrid.ui.fragment.exposure

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import com.openar.healthgrid.R
import com.openar.healthgrid.repository.HeatZonesRepository
import com.openar.healthgrid.ui.activity.exposure.HeatZonesViewModel
import kotlinx.android.synthetic.main.fragment_exposure_start.*


class ExposureResultFragment : Fragment() {
    private var actionListener: ExposureResultFragmentAction? = null
    private var hasExposure = true
    private val heatZonesViewModel: HeatZonesViewModel by activityViewModels()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        hasExposure = HeatZonesRepository.instance.exposureInfo?.size ?: 0 != 0
        return inflater.inflate(R.layout.fragment_exposure_start, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        val density = requireActivity().resources.displayMetrics.density
        val textContainerParams = text_container.layoutParams as ViewGroup.MarginLayoutParams
        textContainerParams.marginStart = (54 * density).toInt()
        textContainerParams.marginEnd = (54 * density).toInt()
        skip_button.visibility = View.GONE
        exposure_title.visibility = View.INVISIBLE
        exposure_message.text =
            if (hasExposure) getString(R.string.exposure_true_message) else getString(R.string.exposure_false_message)
        exposure_image.setImageDrawable(
            ContextCompat.getDrawable(
                requireContext(),
                if (hasExposure) R.drawable.ic_exposure_true else R.drawable.ic_exposure_false
            )
        )
        next_button.text =
            if (hasExposure) getString(R.string.exposure_more_info) else getString(R.string.exposure_main_menu)
        next_button.setOnClickListener {
            if(hasExposure)
                actionListener?.needMoreInfo()
            else
                actionListener?.navigateToMap()
        }
    }


    override fun onAttach(context: Context) {
        super.onAttach(context)
        actionListener = activity as ExposureResultFragmentAction
    }

    override fun onDetach() {
        actionListener = null
        super.onDetach()
    }

    interface ExposureResultFragmentAction {
        fun needMoreInfo()
        fun navigateToMap()
    }

    companion object {
        const val EXPOSURE_RESULT_TAG = "EXPOSURE_RESULT"
        fun newInstance(): ExposureResultFragment = ExposureResultFragment()
    }
}
