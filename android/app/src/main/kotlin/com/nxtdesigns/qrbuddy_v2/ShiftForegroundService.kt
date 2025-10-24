package com.nxtdesigns.qrbuddy_v2

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.*
import android.widget.ImageView
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class ShiftForegroundService : Service() {

    companion object {
        const val CHANNEL_ID = "shift_channel"
        const val ACTION_START = "com.nxtdesigns.qrbuddy_v2.START_SHIFT"
        const val ACTION_BREAK = "com.nxtdesigns.qrbuddy_v2.TAKE_BREAK"
        const val ACTION_RESUME = "com.nxtdesigns.qrbuddy_v2.RESUME_SHIFT"
        const val ACTION_END = "com.nxtdesigns.qrbuddy_v2.END_SHIFT"
    }

    // MethodChannel to communicate with Flutter
    private lateinit var channel: MethodChannel

    override fun onCreate() {
        super.onCreate()
        // Initialize MethodChannel
        val engine = FlutterEngineCache.getInstance().get("my_engine")
        if (engine != null) {
            channel = MethodChannel(engine.dartExecutor.binaryMessenger, "com.nxtdesigns.qrbuddy_v2/shift_service")
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        when (action) {
            ACTION_START -> startShiftNotification("Waiting for orders...", showResume = false)
            ACTION_BREAK -> {
                startShiftNotification("On Break - Waiting for orders...", showResume = true)
                // Call Flutter MethodChannel
                if (::channel.isInitialized) channel.invokeMethod("takeBreak", null)
            }
            ACTION_RESUME -> {
                startShiftNotification("Waiting for orders...", showResume = false)
                if (::channel.isInitialized) channel.invokeMethod("resumeShift", null)
            }
            ACTION_END -> {
                stopForeground(true)
                stopSelf()
                if (::channel.isInitialized) channel.invokeMethod("endShift", null)
            }
        }
        return START_STICKY
    }

    private fun startShiftNotification(contentText: String, showResume: Boolean) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Shift Service",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Shows current shift status and actions."
            }
            notificationManager.createNotificationChannel(channel)
        }

        val takeBreakIntent = Intent(this, ShiftForegroundService::class.java).apply { action = ACTION_BREAK }
        val resumeIntent = Intent(this, ShiftForegroundService::class.java).apply { action = ACTION_RESUME }
        val endIntent = Intent(this, ShiftForegroundService::class.java).apply { action = ACTION_END }

        val takeBreakPending = PendingIntent.getService(this, 0, takeBreakIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val resumePending = PendingIntent.getService(this, 1, resumeIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val endPending = PendingIntent.getService(this, 2, endIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

        val openAppIntent = packageManager.getLaunchIntentForPackage(packageName)
        val openAppPending = PendingIntent.getActivity(this, 3, openAppIntent, PendingIntent.FLAG_IMMUTABLE)

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("QR Buddy Shift Active")
            .setContentText(contentText)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(openAppPending)
            .addAction(
                R.drawable.ic_notification,
                if (showResume) "Resume Shift" else "Take Break",
                if (showResume) resumePending else takeBreakPending
            )
            .addAction(R.drawable.ic_notification, "End Shift", endPending)

        startForeground(1001, builder.build())
    }

    override fun onBind(intent: Intent?): IBinder? = null
}