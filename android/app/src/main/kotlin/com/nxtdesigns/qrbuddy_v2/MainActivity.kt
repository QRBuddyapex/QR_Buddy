package com.nxtdesigns.qrbuddy_v2

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.nxtdesigns.qrbuddy_v2/shift_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FlutterEngineCache.getInstance().put("my_engine", flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startShift" -> {
                        val intent = Intent(this, ShiftForegroundService::class.java).apply { action = ShiftForegroundService.ACTION_START }
                        startService(intent)
                        // Do not start floating icon here; let Flutter handle based on app lifecycle
                        result.success(null)
                    }
                    "takeBreak" -> {
                        val intent = Intent(this, ShiftForegroundService::class.java).apply { action = ShiftForegroundService.ACTION_BREAK }
                        startService(intent)
                        result.success(null)
                    }
                    "resumeShift" -> {
                        val intent = Intent(this, ShiftForegroundService::class.java).apply { action = ShiftForegroundService.ACTION_RESUME }
                        startService(intent)
                        result.success(null)
                    }
                    "endShift" -> {
                        stopService(Intent(this, ShiftForegroundService::class.java))
                        stopService(Intent(this, FloatingIconService::class.java))
                        result.success(null)
                    }
                    "startFloatingIcon" -> {
                        val intent = Intent(this, FloatingIconService::class.java)
                        startService(intent)
                        result.success(null)
                    }
                    "stopFloatingIcon" -> {
                        stopService(Intent(this, FloatingIconService::class.java))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}