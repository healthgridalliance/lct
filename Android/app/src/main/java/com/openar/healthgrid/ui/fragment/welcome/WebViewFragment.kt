package com.openar.healthgrid.ui.fragment.welcome

import android.content.res.TypedArray
import android.os.Bundle
import android.text.Spannable
import android.text.SpannableString
import android.text.style.ForegroundColorSpan
import android.text.style.RelativeSizeSpan
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.openar.healthgrid.R
import kotlinx.android.synthetic.main.welcome_fragment_info.*


class WebPageFragment : Fragment() {
    private lateinit var webLinkArray: TypedArray
    private lateinit var webTitles: TypedArray
    private var pageNumber: Int = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initVariables()
    }

    private fun initVariables() {
        pageNumber = if (arguments != null) arguments?.getInt("num") ?: 1 else 1
        webLinkArray = resources.obtainTypedArray(R.array.web_links)
        webTitles = resources.obtainTypedArray(R.array.web_titles)
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? = inflater.inflate(R.layout.welcome_fragment_info, container, false)

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        description_title.text = webTitles.getText(pageNumber)
        if (pageNumber == 1) {
            // TODO remove when web view links will be added
            val wordToSpan: Spannable = SpannableString(webLinkArray.getText(pageNumber))
            buildTextSpan(wordToSpan, 0, 1)
            buildTextSpan(wordToSpan, 56, 57)
            buildTextSpan(wordToSpan, 99, 100)
            description.text = wordToSpan
            //end removing part
        } else {
            description.text = webLinkArray.getText(pageNumber)
        }
          // TODO uncomment when web view links will be added
//        web_view.loadUrl(webLinkArray.getText(pageNumber))
    }

    private fun buildTextSpan(span: Spannable, start: Int, end: Int) {
        span.setSpan(RelativeSizeSpan(1.2f), start, end, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        context?.let {
            span.setSpan(
                ForegroundColorSpan(
                    ContextCompat.getColor(it, R.color.base_color)
                ), start, end, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
            )
        }
    }

    companion object {
        fun newInstance(page: Int): WebPageFragment {
            val fragment = WebPageFragment()
            val args = Bundle()
            args.putInt("num", page)
            fragment.arguments = args
            return fragment
        }
    }
}
