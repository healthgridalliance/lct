package com.openar.healthgrid.ui.activity.welcome

import android.content.Intent
import android.os.Bundle
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.map.NetworkActivity
import com.openar.healthgrid.ui.fragment.welcome.PrivacyRulesFragment
import com.openar.healthgrid.ui.fragment.welcome.StartJourneyFragment


class WelcomeActivity : NetworkActivity(),
    StartJourneyFragment.StartJourneyFragmentAction,
    PrivacyRulesFragment.PrivacyRulesFragmentAction {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_welcome)
        supportFragmentManager.beginTransaction()
            .replace(
                R.id.welcome_fragment,
                StartJourneyFragment.newInstance(),
                StartJourneyFragment.START_JOURNEY_TAG
            )
            .commit()
    }

    override fun needNextFragment() {
        supportFragmentManager.beginTransaction()
            .setCustomAnimations(
                R.anim.fade_in,
                R.anim.fade_out,
                R.anim.fade_in,
                R.anim.fade_out
            )
            .replace(
                R.id.welcome_fragment,
                PrivacyRulesFragment.newInstance(mapsViewModel),
                PrivacyRulesFragment.PRIVACY_RULES_TAG
            )
            .commit()
    }

    override fun agreeButtonTapped() = finish()

    override fun navigationBackPressed() {
        supportFragmentManager.beginTransaction()
            .replace(
                R.id.welcome_fragment,
                StartJourneyFragment.newInstance(true),
                StartJourneyFragment.START_JOURNEY_TAG
            )
            .commit()
    }

    override fun onBackPressed() {
        val homeIntent = Intent(Intent.ACTION_MAIN)
        homeIntent.addCategory(Intent.CATEGORY_HOME)
        homeIntent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
        startActivity(homeIntent)
    }
}
