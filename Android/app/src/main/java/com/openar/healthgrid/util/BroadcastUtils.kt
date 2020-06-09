package com.openar.healthgrid.util

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.localbroadcastmanager.content.LocalBroadcastManager

object BroadcastUtils {
    fun sendBroadcast(context: Context, action: String, extras: Bundle = Bundle()) {
        Intent().also { intent ->
            intent.action = action
            intent.putExtras(extras)
            LocalBroadcastManager.getInstance(context).sendBroadcast(intent)
        }
    }
}