package com.openar.healthgrid.ui.activity.map.dialog.adapter

import android.view.View
import androidx.recyclerview.widget.*
import kotlin.math.sign


class EndSnapHelper(activeDaysNumber: Int) : LinearSnapHelper() {
    private val lastActivePosition: Int = activeDaysNumber - 1
    private var mHorizontalHelper: OrientationHelper? = null
    private var lastActiveView: View? = null
    private var needFastScroll: Boolean = false
    private var fastScrollCellsNumber: Int = 1
    private var recyclerView: RecyclerView? = null

    @Throws(IllegalStateException::class)
    override fun attachToRecyclerView(recyclerView: RecyclerView?) {
        super.attachToRecyclerView(recyclerView)
        this.recyclerView = recyclerView
    }

    override fun calculateDistanceToFinalSnap(
        layoutManager: RecyclerView.LayoutManager,
        targetView: View
    ): IntArray? {
        val out = IntArray(2)
        if (layoutManager.canScrollHorizontally()) {
            out[0] = distanceToStart(targetView, getHorizontalHelper(layoutManager))
            if(needFastScroll) {
                out[0] *= fastScrollCellsNumber
                needFastScroll = false
            }
        } else {
            out[0] = 0
        }
        return out
    }

    private fun distanceToStart(targetView: View, helper: OrientationHelper?): Int {
        return if(helper != null) {
            helper.getDecoratedEnd(targetView) - helper.endAfterPadding
        } else 0
    }

    override fun findSnapView(layoutManager: RecyclerView.LayoutManager): View? {
        return if (layoutManager.canScrollHorizontally()) {
            getStartView(layoutManager, getHorizontalHelper(layoutManager))
        } else super.findSnapView(layoutManager)
    }

    private fun getStartView(layoutManager: RecyclerView.LayoutManager, helper: OrientationHelper?): View? {
        if (layoutManager is LinearLayoutManager) {
            val firstChild = layoutManager.findFirstVisibleItemPosition()
            if (firstChild == RecyclerView.NO_POSITION) {
                return null
            }
            val child = layoutManager.findViewByPosition(firstChild)
            return if(helper != null) {
                if(helper.getDecoratedEnd(child) == helper.endAfterPadding) {
                    return null
                }
                if(lastActiveView == null) {
                    lastActiveView = layoutManager.findViewByPosition(lastActivePosition - 1)
                }
                if(firstChild > lastActivePosition) {
                    needFastScroll = true
                    fastScrollCellsNumber = firstChild - lastActivePosition
                    return lastActiveView
                }
                 if ((helper.endAfterPadding - helper.getDecoratedStart(child)) >= helper.getDecoratedMeasurement(child) / 2 &&
                     helper.getDecoratedEnd(child) > 0) {
                    child
                } else {
                     if(firstChild == lastActivePosition) {
                         child
                     } else {
                         layoutManager.findViewByPosition(firstChild + 1)
                     }
                }
            } else null
        }
        return null
    }

    private fun getHorizontalHelper(layoutManager: RecyclerView.LayoutManager): OrientationHelper? {
        if (mHorizontalHelper == null) {
            mHorizontalHelper = OrientationHelper.createHorizontalHelper(layoutManager)
        }
        return mHorizontalHelper
    }


    override fun findTargetSnapPosition(
        layoutManager: RecyclerView.LayoutManager,
        velocityX: Int,
        velocityY: Int
    ): Int {
        if (layoutManager !is RecyclerView.SmoothScroller.ScrollVectorProvider ||
            layoutManager.itemCount == 0 || findSnapView(layoutManager) == null) {
            return RecyclerView.NO_POSITION
        }
        if (layoutManager is LinearLayoutManager) {
            val firstVisible = layoutManager.findFirstVisibleItemPosition()
            val lastVisible = layoutManager.findLastCompletelyVisibleItemPosition()
            val pos = firstVisible - (kotlin.math.abs(lastVisible - firstVisible + 1) / 2) * sign(velocityX * 1.0).toInt()
            needFastScroll = false
            return if(pos < lastActivePosition) pos else lastActivePosition
        }
        return super.findTargetSnapPosition(layoutManager, velocityX, velocityY)
    }
}