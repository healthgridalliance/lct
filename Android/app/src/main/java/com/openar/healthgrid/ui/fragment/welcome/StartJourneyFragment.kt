package com.openar.healthgrid.ui.fragment.welcome

import android.content.Context
import android.content.res.TypedArray
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import androidx.appcompat.app.AppCompatDelegate
import androidx.core.content.res.ResourcesCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import androidx.viewpager.widget.ViewPager
import androidx.viewpager.widget.ViewPager.OnPageChangeListener
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.fragment.welcome.view.WelcomeViewTransformation
import kotlinx.android.synthetic.main.fragment_start_journey.*
import kotlin.math.abs


class StartJourneyFragment : Fragment() {
    private var isLastPage: Boolean = false
    private var lastSelectedItem = 0
    private lateinit var imageArray: TypedArray
    private lateinit var buttonTextArray: TypedArray
    private lateinit var pageChangeListener: OnPageChangeListener
    private lateinit var infoPagerAdapter: InfoPagerAdapter
    private var actionListener: StartJourneyFragmentAction? = null
    private lateinit var nextButton: Button
    private lateinit var welcomeViewPager: ViewPager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        isLastPage = arguments?.getBoolean(LAST_PAGE, false) ?: false
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view: View = inflater.inflate(R.layout.fragment_start_journey, container, false)
        initVariables(view)
        initViewPager()
        return view
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        actionListener = activity as StartJourneyFragmentAction
    }

    override fun onDetach() {
        super.onDetach()
        actionListener = null
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        activity?.window?.attributes?.windowAnimations = R.style.WelcomeScreenImageAnimation
        nextButton.setOnClickListener {
            if (lastSelectedItem == buttonTextArray.length() - 1) {
                actionListener?.needNextFragment()
            } else {
                welcomeViewPager.currentItem = lastSelectedItem + 1
            }
        }
    }

    private fun initVariables(view: View) {
        welcomeViewPager = view.findViewById(R.id.welcome_view_pager)
        imageArray = resources.obtainTypedArray(R.array.welcome_images)
        buttonTextArray = resources.obtainTypedArray(R.array.welcome_button_text)
        nextButton = view.findViewById(R.id.next_button)
    }

    private fun initViewPager() {
        welcomeViewPager.setPageTransformer(false, WelcomeViewTransformation())
        infoPagerAdapter = InfoPagerAdapter(childFragmentManager)
        welcomeViewPager.adapter = infoPagerAdapter
        pageChangeListener = ViewPagerListener(this)
        welcomeViewPager.addOnPageChangeListener(pageChangeListener)
        welcomeViewPager.currentItem = if (isLastPage) imageArray.length() - 1 else 0
    }

    override fun onResume() {
        super.onResume()
        welcomeViewPager.currentItem = lastSelectedItem
    }

    override fun onPause() {
        super.onPause()
        lastSelectedItem = welcomeViewPager.currentItem
    }

    inner class InfoPagerAdapter(fm: FragmentManager) :
        FragmentPagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT) {
        override fun getItem(position: Int): Fragment = WebPageFragment.newInstance(position)

        override fun getCount(): Int = imageArray.length()
    }

    inner class ViewPagerListener(private val fragment: StartJourneyFragment) :
        OnPageChangeListener {
        private val middlePosition = 0.5f
        private var prevPositionOffset: Float = 0f

        override fun onPageScrolled(page: Int, positionOffset: Float, positionOffsetPixels: Int) {
            val alpha: Float = 2f * (positionOffset - middlePosition)
            drawable.setImageResource(imageArray.getResourceId(if (positionOffset > middlePosition) page + 1 else page, R.drawable.ic_welcome_start))
            drawable?.alpha = abs(alpha)
            prevPositionOffset = positionOffset
        }

        override fun onPageSelected(position: Int) {
            lastSelectedItem = position
            nextButton.text = buttonTextArray.getText(position)
        }

        override fun onPageScrollStateChanged(state: Int) {}
    }

    interface StartJourneyFragmentAction {
        fun needNextFragment()
    }

    companion object {
        const val START_JOURNEY_TAG = "START_JOURNEY_TAG"
        const val LAST_PAGE = "is_last_page"
        fun newInstance(isLastPage: Boolean = false): StartJourneyFragment {
            val fragment = StartJourneyFragment()
            val args = Bundle()
            args.putBoolean(LAST_PAGE, isLastPage)
            fragment.arguments = args
            return fragment
        }
    }
}

