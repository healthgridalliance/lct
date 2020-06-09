package com.openar.healthgrid.ui.fragment.welcome

import android.content.Context
import android.graphics.Typeface
import android.os.Bundle
import android.text.Spannable
import android.text.SpannableString
import android.text.style.ForegroundColorSpan
import android.text.style.StyleSpan
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.map.viewmodel.MapsViewModel
import com.openar.healthgrid.util.OfflineNotificationUtils
import com.openar.healthgrid.util.PreferenceStorage
import kotlinx.android.synthetic.main.fragment_privacy_rules.*


class PrivacyRulesFragment private constructor(private val viewModel: MapsViewModel): Fragment() {
    private var actionListener: PrivacyRulesFragmentAction? = null
    private var checkBoxStatus: Boolean = false

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_privacy_rules, container, false)
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        actionListener = activity as PrivacyRulesFragmentAction
    }

    override fun onDetach() {
        actionListener = null
        super.onDetach()
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        activity?.window?.attributes?.windowAnimations = R.style.WelcomeScreenImageAnimation
        buildCheckBoxTextSpan()
        policy_checkbox.setOnCheckedChangeListener { _, value ->
            checkBoxStatus = value
            agree_button.isEnabled = value
            context?.let {
                if (value)
                    agree_button.background = ContextCompat.getDrawable(it, R.drawable.base_button_box_radius)
                else
                    agree_button.background = ContextCompat.getDrawable(it, R.drawable.inactive_base_button_box_radius)
            }
        }

        agree_button.setOnClickListener {
            if (checkBoxStatus && OfflineNotificationUtils.verifyAvailableNetwork(requireContext())) {
                actionListener?.agreeButtonTapped()
                PreferenceStorage.addPropertyBoolean(requireContext(), PreferenceStorage.FIRST_LAUNCH, false)
                viewModel.onFirstAppLaunch()
            }
        }
        leading.setOnClickListener { actionListener?.navigationBackPressed() }
        // TODO replace with real web url
        privacy_web_view.loadUrl("file:///android_asset/privacy_policy_test.html")
    }

    private fun buildCheckBoxTextSpan() {
        val span: Spannable = SpannableString(policy_checkbox.text)
        context?.let {
            span.setSpan(
                ForegroundColorSpan(ContextCompat.getColor(it, R.color.base_color)),
                12, policy_checkbox.text.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
            )
        }
        span.setSpan(StyleSpan(Typeface.BOLD), 12, policy_checkbox.text.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        policy_checkbox.text = span
    }

    interface PrivacyRulesFragmentAction {
        fun agreeButtonTapped()
        fun navigationBackPressed()
    }

    companion object {
        const val PRIVACY_RULES_TAG = "PRIVACY_RULES_TAG"
        fun newInstance(viewModel: MapsViewModel): PrivacyRulesFragment = PrivacyRulesFragment(viewModel)
    }
}
