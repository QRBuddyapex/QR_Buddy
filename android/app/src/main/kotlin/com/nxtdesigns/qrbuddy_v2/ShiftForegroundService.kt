package com.nxtdesigns.qrbuddy_v2

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class ShiftForegroundService : Service() {

    companion object {
        const val CHANNEL_ID = "shift_channel"
        const val ACTION_START = "START_SHIFT"
        const val ACTION_BREAK = "TAKE_BREAK"
        const val ACTION_RESUME = "RESUME_SHIFT"
        const val ACTION_END = "END_SHIFT"
    }

    private var channel: MethodChannel? = null

    override fun onCreate() {
        super.onCreate()
        val engine = FlutterEngineCache.getInstance().get("my_engine")
        if (engine != null) {
            channel = MethodChannel(engine.dartExecutor.binaryMessenger, "com.nxtdesigns.qrbuddy_v2/shift_service")
            Log.d("ShiftForegroundService", "Channel initialized successfully")
        } else {
            Log.e("ShiftForegroundService", "FlutterEngine not found in cache")
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> startShiftNotification("Waiting for orders...", showResume = false)
            ACTION_BREAK -> {
                startShiftNotification("On Break...", showResume = true)
                notifyFlutter("takeBreak")
            }
            ACTION_RESUME -> {
                startShiftNotification("Waiting...", showResume = false)
                notifyFlutter("resumeShift")
            }
            ACTION_END -> {
                notifyFlutter("endShift")
                stopForeground(true)
                stopSelf()
            }
        }
        return START_STICKY
    }

    private fun startShiftNotification(contentText: String, showResume: Boolean) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(CHANNEL_ID, "Shift Service", NotificationManager.IMPORTANCE_HIGH)
            notificationManager.createNotificationChannel(channel)
        }

        val takeBreakIntent = Intent(this, ShiftForegroundService::class.java).apply { action = ACTION_BREAK }
        val resumeIntent = Intent(this, ShiftForegroundService::class.java).apply { action = ACTION_RESUME }
        val endIntent = Intent(this, ShiftForegroundService::class.java).apply { action = ACTION_END }

        val takeBreakPending = PendingIntent.getService(this, 0, takeBreakIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val resumePending = PendingIntent.getService(this, 1, resumeIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val endPending = PendingIntent.getService(this, 2, endIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("QR Buddy Shift Active")
            .setContentText(contentText)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .addAction(
                R.drawable.ic_notification,
                if (showResume) "Resume" else "Break",
                if (showResume) resumePending else takeBreakPending
            )
            .addAction(R.drawable.ic_notification, "End Shift", endPending)

        startForeground(1001, builder.build())
    }

    private fun notifyFlutter(method: String) {
        channel?.let { ch ->
            try {
                ch.invokeMethod(method, null)
                Log.d("ShiftForegroundService", "Invoked Flutter method: $method")
            } catch (e: Exception) {
                Log.e("ShiftForegroundService", "Error invoking Flutter method $method: $e")
            }
        } ?: run {
            Log.e("ShiftForegroundService", "Channel not initialized for method: $method")
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}