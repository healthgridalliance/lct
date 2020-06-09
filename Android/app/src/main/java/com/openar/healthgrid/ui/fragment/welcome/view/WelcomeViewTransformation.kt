package com.openar.healthgrid.ui.fragment.welcome.view

import android.view.View
import androidx.viewpager.widget.ViewPager
import kotlin.math.abs

class WelcomeViewTransformation : ViewPager.PageTransformer {
    override fun transformPage(
        page: View,
        position: Float
    ) {
        if (position <= -1.0f || position >= 1.0f) {
        } else if (position == 0.0f) {
        } else {
            page.alpha = 1.0f - abs(position)
        }
    }
}
