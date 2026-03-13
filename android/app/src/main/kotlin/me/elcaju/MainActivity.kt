package me.elcaju

import android.content.ComponentName
import android.nfc.NfcAdapter
import android.nfc.cardemulation.CardEmulation
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "me.elcaju/nfc_hce"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setPayload" -> {
                    val payload = call.argument<ByteArray>("payload")
                    NfcHceService.ndefPayload = payload

                    // Force Android to route the NDEF AID to our service
                    // instead of manufacturer services (Xiaomi Mi Share, etc.)
                    try {
                        val adapter = NfcAdapter.getDefaultAdapter(this)
                        if (adapter != null) {
                            val cardEmulation = CardEmulation.getInstance(adapter)
                            cardEmulation.setPreferredService(
                                this,
                                ComponentName(this, NfcHceService::class.java)
                            )
                        }
                    } catch (_: Exception) {}

                    result.success(true)
                }
                "clearPayload" -> {
                    NfcHceService.ndefPayload = null

                    // Release preferred service routing
                    try {
                        val adapter = NfcAdapter.getDefaultAdapter(this)
                        if (adapter != null) {
                            val cardEmulation = CardEmulation.getInstance(adapter)
                            cardEmulation.unsetPreferredService(this)
                        }
                    } catch (_: Exception) {}

                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
