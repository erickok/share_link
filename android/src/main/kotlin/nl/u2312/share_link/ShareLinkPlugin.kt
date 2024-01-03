package nl.u2312.share_link

import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class ShareLinkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    private lateinit var channel: MethodChannel
    private lateinit var engineContext: Context
    private var attachedActivity: Activity? = null
    private var lastShareRequest: Result? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        engineContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "share_link")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method != "shareUri") {
            result.notImplemented()
            return
        }

        lastShareRequest = result
        val uri = call.argument<String>("uri")
        val subject = call.argument<String?>("subject")
        ShareLinkResultHandler.lastUri = uri
        ShareLinkResultHandler.lastTarget = null

        // First figure out the apps that support sharing
        val queryShareIntent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, uri)
            if (subject != null) {
                putExtra(Intent.EXTRA_SUBJECT, subject)
            }
        }

        val pm = engineContext.packageManager

        @Suppress("DEPRECATION") // New API isn't used so keep deprecated call
        val targets = pm.queryIntentActivities(queryShareIntent, 0)
        val expectActivityResult = Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1

        // For each target, create its own share intent with utm_source and utm_medium parameters
        // and create a chooser intent with all of them
        val shareIntents = targets.map { target ->
            val utmUri = try {
                UtmUriBuilder(Uri.parse(uri), target.activityInfo.packageName).build().toString()
            } catch (e: Exception) {
                uri // Unexpected URI form: ignore and use original
            }
            val targetIntent = Intent(Intent.ACTION_SEND).apply {
                type = "text/plain"
                putExtra(Intent.EXTRA_TEXT, utmUri)
                if (subject != null) {
                    putExtra(Intent.EXTRA_SUBJECT, subject)
                }
                setPackage(target.activityInfo.packageName)
            }
            targetIntent
        }

        // A base share intent is required to be able to show the chooser
        // Prefer to use GSM ('copy link') so we can 'override' all others via EXTRA_ALTERNATE_INTENTS
        val hasGmsTarget = targets.any { it.activityInfo.packageName == "com.google.android.gms" }
        val chooserBaseIntent =
            if (hasGmsTarget) queryShareIntent.apply { setPackage("com.google.android.gms") }
            else shareIntents.first()
        val chooserInitialIntents =
            if (hasGmsTarget) shareIntents.filterNot { it.`package` == "com.google.android.gms" }
            else shareIntents.filterNot { it == chooserBaseIntent }

        if (attachedActivity == null || !expectActivityResult) {
            // No activity attached any more or unsupported on this platform, so no feedback is possible
            val chooserIntent = Intent.createChooser(
                chooserBaseIntent,
                null
            ).apply {
                // These contain the links with utm_source and utm_medium parameters and will be put in front
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    putExtra(Intent.EXTRA_ALTERNATE_INTENTS, shareIntents.toTypedArray())
                } else {
                    putExtra(Intent.EXTRA_INITIAL_INTENTS, chooserInitialIntents.toTypedArray())
                }
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            engineContext.startActivity(chooserIntent)
            // Always assume success in sharing
            lastShareRequest = null
            result.success(mapOf("success" to true, "uri" to uri))
            return
        }

        // Chooser with IntentSender to handle the feedback
        val chooserIntent =
            Intent.createChooser(
                chooserBaseIntent,
                null,
                PendingIntent.getBroadcast(
                    engineContext,
                    0,
                    Intent(engineContext, ShareLinkResultHandler::class.java),
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        PendingIntent.FLAG_MUTABLE
                    } else {
                        0
                    }
                ).intentSender
            ).apply {
                // These contain the links with utm_source and utm_medium parameters and will be put in front
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    putExtra(Intent.EXTRA_ALTERNATE_INTENTS, shareIntents.toTypedArray())
                } else {
                    putExtra(Intent.EXTRA_INITIAL_INTENTS, chooserInitialIntents.toTypedArray())
                }
            }

        try {
            // Shown chooser; the result is send back after the user has chosen a target (or nothing)
            attachedActivity!!.startActivityForResult(chooserIntent, ShareLinkResultHandler.ACTIVITY_RESULT_CODE)
        } catch (e: Exception) {
            lastShareRequest = null
            result.success(mapOf("success" to false, "uri" to uri))
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != ShareLinkResultHandler.ACTIVITY_RESULT_CODE) {
            return false // Not the result to our request
        }
        val request = lastShareRequest ?: return false // No pending share request
        val lastUri = ShareLinkResultHandler.lastUri ?: return false // No pending share request
        val lastTarget = ShareLinkResultHandler.lastTarget?.substringBefore("/")
        lastShareRequest = null

        Log.e("EKO", "lastTarget: $lastTarget")
        Log.e("EKO", "lastUri: $lastUri")
        Log.e("EKO", "resultCode: $resultCode")
        if (lastTarget == null && resultCode != Activity.RESULT_OK) {
            // Sharing was cancelled by the user
            request.success(mapOf("success" to false, "uri" to lastUri))
            return true
        }

        // Sharing was completed
        request.success(
            mapOf(
                "success" to true,
                "uri" to if (lastTarget != null) UtmUriBuilder(Uri.parse(lastUri), lastTarget).build()
                    .toString() else lastUri,
                "target" to lastTarget
            )
        )
        return true
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        attachedActivity = null
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        attachedActivity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        attachedActivity = binding.activity
    }

    override fun onDetachedFromActivity() {
        attachedActivity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        attachedActivity = null
    }
}
