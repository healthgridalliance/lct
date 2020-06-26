package com.openar.healthgrid.ui.activity.welcome

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.map.MapsMainActivity
import com.openar.healthgrid.ui.activity.map.NetworkActivity
import com.openar.healthgrid.ui.fragment.welcome.PrivacyRulesFragment
import com.openar.healthgrid.ui.fragment.welcome.StartJourneyFragment
import com.openar.healthgrid.util.PermissionUtils
import com.openar.healthgrid.util.PermissionUtils.REQUEST_CHECK_SETTINGS
import com.openar.healthgrid.util.PreferenceStorage
import kotlinx.android.synthetic.main.fragment_start_journey.*


class WelcomeActivity : NetworkActivity(),
    StartJourneyFragment.StartJourneyFragmentAction,
    PrivacyRulesFragment.PrivacyRulesFragmentAction {
    private var hasLocationPermission = false
    private var locationServicesSwitchedOn = false

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
                PrivacyRulesFragment.newInstance(),
                PrivacyRulesFragment.PRIVACY_RULES_TAG
            )
            .commit()
    }

    override fun agreeButtonTapped() {
        hasLocationPermission = PermissionUtils.checkLocationPermission(this)
        PermissionUtils.checkGeolocationServicesSwitchedOn(this, this::geolocationSwitchedOn)
    }

    private fun geolocationSwitchedOn(res: Boolean) {
        locationServicesSwitchedOn = res
        tryOpenNextScreen()
    }

    private fun tryOpenNextScreen() {
        if (hasLocationPermission && locationServicesSwitchedOn) {
            PreferenceStorage.addPropertyBoolean(this, PreferenceStorage.FIRST_LAUNCH, false)
            finish()
        }
    }

    private fun startMapActivity() {
        PreferenceStorage.addPropertyBoolean(this, PreferenceStorage.FIRST_LAUNCH, false)
        val intent = Intent(this, MapsMainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
        finish()
    }

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
         val curFragment = supportFragmentManager.findFragmentByTag(StartJourneyFragment.START_JOURNEY_TAG)
         if(curFragment != null && curFragment.isVisible) {
             val curItem = curFragment.welcome_view_pager.currentItem
             if(curItem == 0) {
                 val homeIntent = Intent(Intent.ACTION_MAIN)
                 homeIntent.addCategory(Intent.CATEGORY_HOME)
                 homeIntent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
                 startActivity(homeIntent)
             } else {
                 curFragment.welcome_view_pager.currentItem = curItem - 1
             }
         } else {
             navigationBackPressed()
         }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when(requestCode) {
             REQUEST_CHECK_SETTINGS -> {
                 PreferenceStorage.addPropertyBoolean(this, PreferenceStorage.GEOLOCATION_DIALOG_VISIBLE, false)
                 when(resultCode) {
                     Activity.RESULT_OK -> {
                         locationServicesSwitchedOn = true
                         tryOpenNextScreen()
                     }
                     Activity.RESULT_CANCELED -> {
                         locationServicesSwitchedOn = false
                         startMapActivity()
                     }
                 }
             }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        when (requestCode) {
            MapsMainActivity.LOCATION_PERMISSION_REQUEST_CODE -> {
                if ((grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
                    hasLocationPermission = true
                    tryOpenNextScreen()
                } else {
                    hasLocationPermission = true
                    startMapActivity()
                }
                return
            }
        }
    }
}
