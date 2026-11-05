package com.zoli.app

import android.content.Context
import android.os.Build
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.zoli.app/unione_ussd"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "getActiveSims" -> result.success(activeSims())
                "executeUssd" -> executeUssd(call, result)
                else -> result.notImplemented()
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun activeSims(): List<Map<String, Any?>> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP_MR1) return emptyList()
        val subscriptions = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
        return try {
            (subscriptions.activeSubscriptionInfoList ?: emptyList()).map { info ->
                mapOf(
                    "subscriptionId" to info.subscriptionId,
                    "label" to (info.displayName?.toString() ?: "Carte SIM ${info.simSlotIndex + 1}"),
                    "operatorName" to info.carrierName?.toString()
                )
            }
        } catch (_: SecurityException) {
            emptyList()
        }
    }

    private fun executeUssd(call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            result.error("UNSUPPORTED", "Les réponses USSD nécessitent Android 8 ou une version ultérieure.", null)
            return
        }
        val code = call.argument<String>("code")
        if (code.isNullOrBlank()) {
            result.error("INVALID_CODE", "Code USSD vide.", null)
            return
        }
        val subscriptionId = call.argument<Int>("subscriptionId")
        @Suppress("DEPRECATION")
        val baseManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val manager = if (subscriptionId != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            baseManager.createForSubscriptionId(subscriptionId)
        } else baseManager
        sendUssd(manager, code, result)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun sendUssd(manager: TelephonyManager, code: String, result: MethodChannel.Result) {
        try {
            manager.sendUssdRequest(code, object : TelephonyManager.UssdResponseCallback() {
                override fun onReceiveUssdResponse(telephonyManager: TelephonyManager, request: String, response: CharSequence) {
                    result.success(mapOf("success" to true, "response" to response.toString()))
                }

                override fun onReceiveUssdResponseFailed(telephonyManager: TelephonyManager, request: String, failureCode: Int) {
                    result.success(mapOf("success" to false, "error" to "USSD_FAILURE_$failureCode"))
                }
            }, null)
        } catch (error: SecurityException) {
            result.success(mapOf("success" to false, "error" to "PERMISSION_DENIED"))
        } catch (error: Exception) {
            result.success(mapOf("success" to false, "error" to (error.message ?: "USSD_ERROR")))
        }
    }
}
