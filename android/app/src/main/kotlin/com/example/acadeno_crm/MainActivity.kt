package com.example.acadeno_crm

import android.Manifest
import android.content.pm.PackageManager
import android.provider.CallLog
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.acadeno.crm/call_logs"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getCallLogs" -> {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CALL_LOG)
                        != PackageManager.PERMISSION_GRANTED
                    ) {
                        result.error("PERMISSION_DENIED", "READ_CALL_LOG permission not granted", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val logs = mutableListOf<Map<String, Any?>>()
                        val projection = arrayOf(
                            CallLog.Calls.NUMBER,
                            CallLog.Calls.DATE,
                            CallLog.Calls.DURATION,
                            CallLog.Calls.TYPE,
                            CallLog.Calls.CACHED_NAME,
                        )
                        val cursor = contentResolver.query(
                            CallLog.Calls.CONTENT_URI,
                            projection,
                            null,
                            null,
                            "${CallLog.Calls.DATE} DESC"
                        )

                        cursor?.use {
                            val numberIdx = it.getColumnIndex(CallLog.Calls.NUMBER)
                            val dateIdx   = it.getColumnIndex(CallLog.Calls.DATE)
                            val durIdx    = it.getColumnIndex(CallLog.Calls.DURATION)
                            val typeIdx   = it.getColumnIndex(CallLog.Calls.TYPE)
                            val nameIdx   = it.getColumnIndex(CallLog.Calls.CACHED_NAME)

                            while (it.moveToNext()) {
                                val type = when (it.getInt(typeIdx)) {
                                    CallLog.Calls.OUTGOING_TYPE -> "outgoing"
                                    CallLog.Calls.INCOMING_TYPE -> "answered"
                                    CallLog.Calls.MISSED_TYPE   -> "missed"
                                    CallLog.Calls.REJECTED_TYPE -> "missed"
                                    else -> "outgoing"
                                }
                                val ts = it.getLong(dateIdx)
                                val sdf = SimpleDateFormat("MMM d, h:mm a", Locale.getDefault())
                                val dateStr = sdf.format(Date(ts))

                                val dur = it.getLong(durIdx)
                                val durStr = if (dur > 0) {
                                    val m = dur / 60
                                    val s = dur % 60
                                    if (m > 0) "${m}m ${s}s" else "${s}s"
                                } else ""

                                logs.add(mapOf(
                                    "number"    to (it.getString(numberIdx) ?: ""),
                                    "name"      to (it.getString(nameIdx) ?: ""),
                                    "date"      to dateStr,
                                    "duration"  to durStr,
                                    "type"      to type,
                                    "timestamp" to ts,
                                ))
                            }
                        }
                        result.success(logs)
                    } catch (e: Exception) {
                        result.error("FETCH_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
