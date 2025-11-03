package com.nxtdesigns.qrbuddy_apexv3

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.*
import android.view.animation.AccelerateDecelerateInterpolator
import android.widget.ImageView
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class FloatingIconService : Service() {
    private lateinit var windowManager: WindowManager
    private lateinit var floatingView: View
    private lateinit var icon: ImageView
    private lateinit var channel: MethodChannel
    private var initialX = 0
    private var initialY = 0
    private var touchX = 0f
    private var touchY = 0f
    private var isViewAdded = false

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        // MethodChannel to Flutter (for potential future use, e.g., buttons)
        val engine = FlutterEngineCache.getInstance().get("my_engine")
        if (engine != null) {
            channel = MethodChannel(engine.dartExecutor.binaryMessenger, "com.nxtdesigns.qrbuddy_apexv3/shift_service")
            Log.d("FloatingIconService", "Channel initialized successfully")
        } else {
            Log.e("FloatingIconService", "FlutterEngine not found in cache")
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        if (!isViewAdded) {
            addFloatingView()
        }
        // Make the service sticky so it restarts if killed
        return START_STICKY
    }

    private fun addFloatingView() {
        val layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )
        layoutParams.gravity = Gravity.TOP or Gravity.END
        layoutParams.x = 20
        layoutParams.y = 100

        floatingView = LayoutInflater.from(this).inflate(R.layout.overlay_icon, null)
        icon = floatingView.findViewById(R.id.floating_icon)

        // Animate appearance
        icon.scaleX = 0f
        icon.scaleY = 0f
        icon.animate()
            .scaleX(1f)
            .scaleY(1f)
            .setDuration(300)
            .setInterpolator(AccelerateDecelerateInterpolator())
            .start()

        icon.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = layoutParams.x
                    initialY = layoutParams.y
                    touchX = event.rawX
                    touchY = event.rawY
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    layoutParams.x = initialX + (touchX - event.rawX).toInt()
                    layoutParams.y = initialY + (event.rawY - touchY).toInt()
                    windowManager.updateViewLayout(floatingView, layoutParams)
                    true
                }
                MotionEvent.ACTION_UP -> {
                    // Tap detection
                    if (Math.abs(event.rawX - touchX) < 10 && Math.abs(event.rawY - touchY) < 10) {
                        launchApp()
                    }
                    true
                }
                else -> false
            }
        }
        windowManager.addView(floatingView, layoutParams)
        isViewAdded = true
        Log.d("FloatingIconService", "Floating view added")
    }

    private fun removeFloatingView() {
        if (isViewAdded) {
            try {
                windowManager.removeView(floatingView)
                isViewAdded = false
                Log.d("FloatingIconService", "Floating view removed")
            } catch (e: Exception) {
                Log.e("FloatingIconService", "Error removing view: $e")
            }
        }
    }

    private fun launchApp() {
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            // Add extra to indicate launched from floating icon if needed
            putExtra("from_floating_icon", true)
        }
        startActivity(intent)
        Log.d("FloatingIconService", "Launching app from floating icon")
    }

    override fun onDestroy() {
        super.onDestroy()
        removeFloatingView()
        Log.d("FloatingIconService", "Service destroyed")
    }

    override fun onBind(intent: Intent?): IBinder? = null
}