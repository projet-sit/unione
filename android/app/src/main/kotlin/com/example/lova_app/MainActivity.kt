package com.zoli.app

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.telephony.TelephonyManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channelName = "com.zoli.app/unione_ussd"
    private val deviceChannelName = "com.zoli.app/unione_device"
    private val apkChannelName = "com.zoli.app/unione_apk"
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
        // Informations techniques non personnelles pour les signalements.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, deviceChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceInfo" -> result.success(deviceInfo())
                else -> result.notImplemented()
            }
        }
        // Partage du fichier APK installé (copie cache + vérification signature).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, apkChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "prepareApkShare" -> prepareApkShare(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun prepareApkShare(result: MethodChannel.Result) {
        try {
            val source = File(applicationInfo.sourceDir)
            if (!source.exists() || source.length() == 0L) {
                result.error("APK_NOT_FOUND", "APK installé introuvable.", null)
                return
            }
            if (!hasMatchingSignature(source)) {
                result.error(
                    "APK_SIGNATURE_INVALID",
                    "La signature de l'APK ne correspond pas à l'application.",
                    null,
                )
                return
            }
            val directory = File(cacheDir, "shared_apk").apply { mkdirs() }
            directory.listFiles()?.forEach { it.delete() }
            val version = packageManager.getPackageInfo(packageName, 0).versionName ?: "apk"
            val destination = File(directory, "UNIONE-$version.apk")
            source.copyTo(destination, overwrite = true)
            result.success(
                mapOf(
                    "path" to destination.absolutePath,
                    "size" to destination.length(),
                ),
            )
        } catch (error: Exception) {
            Log.e(tag, "Partage de l'APK impossible", error)
            result.error("APK_SHARE_FAILED", error.message, null)
        }
    }

    @Suppress("DEPRECATION")
    private fun hasMatchingSignature(apk: File): Boolean {
        val manager = packageManager
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            PackageManager.GET_SIGNING_CERTIFICATES
        } else {
            PackageManager.GET_SIGNATURES
        }
        return try {
            val archive = manager.getPackageArchiveInfo(apk.absolutePath, flags) ?: return false
            val installed = manager.getPackageInfo(packageName, flags)
            val archiveSigners = signatureHashes(archive)
            val installedSigners = signatureHashes(installed)
            archiveSigners.isNotEmpty() && archiveSigners == installedSigners
        } catch (error: Exception) {
            Log.e(tag, "Vérification de signature impossible", error)
            false
        }
    }

    @Suppress("DEPRECATION")
    private fun signatureHashes(info: PackageInfo): Set<Int> {
        val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            info.signingInfo?.apkContentsSigners
        } else {
            info.signatures
        } ?: return emptySet()
        return signatures.map { it.toByteArray().contentHashCode() }.toSet()
    }

    private fun deviceInfo(): Map<String, String> {
        val model = listOf(Build.MANUFACTURER, Build.MODEL)
            .filter { it.isNotBlank() }
            .joinToString(" ")
        return mapOf(
            "androidVersion" to Build.VERSION.RELEASE,
            "sdkInt" to Build.VERSION.SDK_INT.toString(),
            "model" to model,
        )
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
