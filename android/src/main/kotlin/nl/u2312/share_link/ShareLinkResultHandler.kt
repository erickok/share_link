package nl.u2312.share_link

import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi

/**
 * Should be set on the PendingIntent.sendBroadcast(...) call. This receiver's
 * onReceive is then called when the user has chosen a share target.
 */
internal class ShareLinkResultHandler : BroadcastReceiver() {
    companion object {
        const val ACTIVITY_RESULT_CODE = 0x2312
        var lastTarget: String? = null
        var lastUri: String? = null
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP_MR1)
    override fun onReceive(context: Context?, intent: Intent) {
        val chosenComponent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(Intent.EXTRA_CHOSEN_COMPONENT, ComponentName::class.java)
        } else {
            @Suppress("DEPRECATION") // Only used on older platforms
            intent.getParcelableExtra(Intent.EXTRA_CHOSEN_COMPONENT)
        }

        Log.e("EKO", "chosenComponent: $chosenComponent")
        lastTarget = chosenComponent?.flattenToString()
    }
}