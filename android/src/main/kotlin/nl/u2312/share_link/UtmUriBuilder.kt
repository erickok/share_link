package nl.u2312.share_link

import android.net.Uri

class UtmUriBuilder(
    private val rawUri: Uri,
    private val packageName: String
) {
    fun build(): Uri {
        val utmSource = when (packageName) {
            "com.facebook.katana" -> "facebook"
            "com.facebook.lite" -> "facebook"
            "com.instagram.android" -> "instagram"
            "com.instagram.barcelona" -> "threads"
            "com.twitter.android" -> "x"
            "com.facebook.orca" -> "messenger"
            "org.telegram.messenger" -> "telegram"
            "org.thoughtcrime.securesms" -> "signal"
            "com.Slack" -> "slack"
            "xyz.blueskyweb.app" -> "bluesky"
            "com.google.android.apps.messaging" -> "sms"
            "com.samsung.android.messaging" -> "sms"
            "com.google.android.gm" -> "mail"
            "com.samsung.android.email.provider" -> "mail"
            "ch.protonmail.android" -> "mail"
            "com.zoho.mail" -> "mail"
            else -> packageName.substringAfterLast(".")
        }
        val utmMedium = when (packageName) {
            "com.android.chrome" -> "web"
            "org.mozilla.firefox" -> "web"
            "com.sec.android.app.sbrowser" -> "web"
            "com.opera.browser" -> "web"
            "com.microsoft.emmx" -> "web"
            "com.brave.browser" -> "web"
            "com.google.android.gm" -> "email"
            "com.microsoft.office.outlook" -> "email"
            "ch.protonmail.android" -> "email"
            "com.zoho.mail" -> "email"
            else -> "social"
        }
        return rawUri.buildUpon()
            .appendQueryParameter("utm_source", utmSource)
            .appendQueryParameter("utm_medium", utmMedium)
            .build()
    }
}