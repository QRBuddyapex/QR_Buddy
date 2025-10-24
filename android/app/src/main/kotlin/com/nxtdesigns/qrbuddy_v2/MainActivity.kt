package com.nxtdesigns.qrbuddy_v2

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.nxtdesigns.qrbuddy_v2/shift_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startShift" -> {
                        startService(Intent(this, ShiftForegroundService::class.java).apply { action = ShiftForegroundService.ACTION_START })
                        startService(Intent(this, FloatingIconService::class.java))
                        result.success(null)
                    }
                    "takeBreak" -> {
                        startService(Intent(this, ShiftForegroundService::class.java).apply { action = ShiftForegroundService.ACTION_BREAK })
                        result.success(null)
                    }
                    "resumeShift" -> {
                        startService(Intent(this, ShiftForegroundService::class.java).apply { action = ShiftForegroundService.ACTION_RESUME })
                        result.success(null)
                    }
                    "endShift" -> {
                        stopService(Intent(this, ShiftForegroundService::class.java))
                        stopService(Intent(this, FloatingIconService::class.java))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
