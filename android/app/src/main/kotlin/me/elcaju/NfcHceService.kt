package me.elcaju

import android.nfc.cardemulation.HostApduService
import android.os.Bundle
import android.util.Log

/**
 * Host Card Emulation service that makes the phone act as an NFC Forum Type 4 tag.
 * Another phone in reader mode can tap and read the NDEF message we serve.
 *
 * The payload is set from Flutter via MainActivity's MethodChannel.
 */
class NfcHceService : HostApduService() {

    companion object {
        private const val TAG = "NfcHceService"

        // Shared payload - set by Flutter via MethodChannel
        @Volatile
        var ndefPayload: ByteArray? = null

        private val OK = byteArrayOf(0x90.toByte(), 0x00.toByte())
        private val NOT_FOUND = byteArrayOf(0x6A.toByte(), 0x82.toByte())

        // Capability Container (CC) file - fixed structure
        // MLe=0xFF (255), MLc=0xFF (255), max NDEF=0x70FF (28671)
        // Compatible with Numo
        private val CC_FILE = byteArrayOf(
            0x00, 0x0F,                         // CC length (15)
            0x20,                                // Mapping version 2.0
            0x00, 0xFF.toByte(),                 // MLe: max read 255 bytes
            0x00, 0xFF.toByte(),                 // MLc: max write 255 bytes
            0x04, 0x06,                          // NDEF File Control TLV
            0xE1.toByte(), 0x04,                 // NDEF file ID
            0x70, 0xFF.toByte(),                 // Max NDEF size: 28671 bytes
            0x00,                                // Read access: open
            0xFF.toByte()                        // Write access: denied
        )
    }

    private var selectedFile: String = "none"
    private var ndefFileCache: ByteArray? = null

    override fun processCommandApdu(commandApdu: ByteArray, extras: Bundle?): ByteArray {
        if (commandApdu.size < 4) return NOT_FOUND

        val ins = commandApdu[1]

        // SELECT command
        if (ins == 0xA4.toByte()) {
            return handleSelect(commandApdu)
        }

        // READ BINARY command
        if (ins == 0xB0.toByte()) {
            return handleRead(commandApdu)
        }

        return NOT_FOUND
    }

    private fun handleSelect(apdu: ByteArray): ByteArray {
        // Select ElCaju proprietary AID (F04543414A5500)
        // Avoids conflicts with Xiaomi Mi Share / Samsung Beam
        if (apdu.size >= 12 && apdu[5] == 0xF0.toByte() && apdu[6] == 0x45.toByte()) {
            selectedFile = "app"
            Log.d(TAG, "Selected ElCaju Application (proprietary AID)")
            return OK
        }

        // Select NDEF Application (AID: D2760000850101)
        if (apdu.size >= 12 && apdu[5] == 0xD2.toByte() && apdu[6] == 0x76.toByte()) {
            selectedFile = "app"
            Log.d(TAG, "Selected NDEF Application")
            return OK
        }

        // Select by file ID
        if (apdu.size >= 7) {
            val fileId = ((apdu[5].toInt() and 0xFF) shl 8) or (apdu[6].toInt() and 0xFF)
            when (fileId) {
                0xE103 -> {
                    selectedFile = "cc"
                    Log.d(TAG, "Selected CC file")
                    return OK
                }
                0xE104 -> {
                    selectedFile = "ndef"
                    // Cache the NDEF file when selected
                    val payload = ndefPayload
                    if (payload != null) {
                        val file = ByteArray(2 + payload.size)
                        file[0] = (payload.size shr 8).toByte()
                        file[1] = (payload.size and 0xFF).toByte()
                        System.arraycopy(payload, 0, file, 2, payload.size)
                        ndefFileCache = file
                        Log.d(TAG, "Selected NDEF file (${payload.size} bytes payload)")
                    } else {
                        ndefFileCache = null
                        Log.w(TAG, "Selected NDEF file but no payload set")
                    }
                    return OK
                }
            }
        }

        return NOT_FOUND
    }

    private fun handleRead(apdu: ByteArray): ByteArray {
        if (apdu.size < 5) return NOT_FOUND

        val offset = ((apdu[2].toInt() and 0xFF) shl 8) or (apdu[3].toInt() and 0xFF)
        // Le=0x00 means 256 bytes in short APDU encoding
        var length = apdu[4].toInt() and 0xFF
        if (length == 0) length = 256

        val data = when (selectedFile) {
            "cc" -> CC_FILE
            "ndef" -> ndefFileCache ?: return NOT_FOUND
            else -> return NOT_FOUND
        }

        if (offset >= data.size) {
            Log.w(TAG, "Read offset $offset beyond data size ${data.size}")
            return NOT_FOUND
        }

        val end = minOf(offset + length, data.size)
        val response = data.copyOfRange(offset, end)
        Log.d(TAG, "Read $selectedFile: offset=$offset len=$length returned=${response.size} bytes")
        return response + OK
    }

    override fun onDeactivated(reason: Int) {
        Log.d(TAG, "Deactivated (reason=$reason)")
        selectedFile = "none"
        ndefFileCache = null
    }
}
