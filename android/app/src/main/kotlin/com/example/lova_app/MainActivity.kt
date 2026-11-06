package com.zoli.app

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.telephony.TelephonyManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.zoli.app/unione_ussd"
    private val tag = "UNIONE/USSD"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "launchUssd" -> launchUssd(call, result)
                "dialUssd" -> dialUssd(call, result)
                "getSimOperator" -> result.success(simOperator())
                else -> result.notImplemented()
            }
        }
    }

    // Lance le code USSD via ACTION_CALL : le système se comporte exactement
    // comme si l'utilisateur avait composé le code au clavier. Aucune SIM n'est
    // transmise : Android affiche sa propre fenêtre de choix de SIM (ou utilise
    // la SIM par défaut des appels), puis ouvre le dialogue USSD de l'opérateur.
    private fun launchUssd(call: MethodCall, result: MethodChannel.Result) {
        val code = call.argument<String>("code")
        if (code.isNullOrBlank()) {
            result.error("INVALID_CODE", "Code USSD vide.", null)
            return
        }
        val uri = telUri(code)
        Log.d(tag, "ACTION_CALL $uri")
        try {
            startActivity(Intent(Intent.ACTION_CALL, uri))
            result.success(true)
        } catch (error: SecurityException) {
            Log.e(tag, "ACTION_CALL refusé (CALL_PHONE)", error)
            result.error("CALL_PERMISSION_DENIED", error.message, null)
        } catch (error: ActivityNotFoundException) {
            Log.e(tag, "Aucune activité pour ACTION_CALL", error)
            result.error("CALL_ACTIVITY_NOT_FOUND", error.message, null)
        } catch (error: Exception) {
            Log.e(tag, "Échec ACTION_CALL", error)
            result.error("CALL_FAILED", error.message, null)
        }
    }

    // Repli : composeur pré-rempli, sans lancer l'appel.
    private fun dialUssd(call: MethodCall, result: MethodChannel.Result) {
        val code = call.argument<String>("code")
        if (code.isNullOrBlank()) {
            result.error("INVALID_CODE", "Code USSD vide.", null)
            return
        }
        val uri = telUri(code)
        Log.d(tag, "ACTION_DIAL $uri")
        try {
            startActivity(Intent(Intent.ACTION_DIAL, uri))
            result.success(true)
        } catch (error: ActivityNotFoundException) {
            Log.e(tag, "Aucune activité pour ACTION_DIAL", error)
            result.error("DIAL_ACTIVITY_NOT_FOUND", error.message, null)
        } catch (error: Exception) {
            Log.e(tag, "Échec ACTION_DIAL", error)
            result.error("DIAL_FAILED", error.message, null)
        }
    }

    // `#` doit être encodé (`%23`) dans l'URI tel:, sinon Android le traite
    // comme un fragment et tronque le code. `Uri.encode` conserve les `*`.
    private fun telUri(code: String): Uri = Uri.parse("tel:" + Uri.encode(code))

    // Détection « au mieux » de l'opérateur de la SIM par défaut.
    // getSimOperator() ne requiert aucune permission.
    private fun simOperator(): String? {
        val manager = getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
        return manager?.simOperator?.takeIf { it.isNotBlank() }
    }
}
