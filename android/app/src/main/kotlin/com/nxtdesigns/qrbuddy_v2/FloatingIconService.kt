package com.nxtdesigns.qrbuddy_v2

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.*
import android.widget.ImageView
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.sin

class FloatingIconService : Service() {

    private lateinit var windowManager: WindowManager
    private lateinit var floatingView: View
    private lateinit var icon: ImageView
    private var isMenuOpen = false
    private val menuButtons = mutableListOf<ImageView>()
    private val radius = 200

    private lateinit var channel: MethodChannel

    private var initialX = 0
    private var initialY = 0
    private var touchX = 0f
    private var touchY = 0f

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

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

        // MethodChannel to Flutter
        val engine = FlutterEngineCache.getInstance().get("my_engine")
        if (engine != null) {
            channel = MethodChannel(engine.dartExecutor.binaryMessenger, "com.nxtdesigns.qrbuddy_v2/shift_service")
            Log.d("FloatingIconService", "Channel initialized successfully")
        } else {
            Log.e("FloatingIconService", "FlutterEngine not found in cache")
        }

        icon.setOnTouchListener { v, event ->
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
                    if (abs(event.rawX - touchX) < 10 && abs(event.rawY - touchY) < 10) {
                        toggleMenu()
                    }
                    true
                }
                else -> false
            }
        }

        windowManager.addView(floatingView, layoutParams)
    }

    private fun toggleMenu() {
        if (!isMenuOpen) openMenu() else closeMenu()
        isMenuOpen = !isMenuOpen
    }

    private fun openMenu() {
        val actions = listOf(
            Triple(android.R.drawable.ic_media_pause, "BREAK") { sendFlutter("takeBreak") },
            Triple(android.R.drawable.ic_media_play, "START") { sendFlutter("resumeShift") },
            Triple(android.R.drawable.ic_menu_close_clear_cancel, "END") { sendFlutter("endShift") },
        )
        val angles = listOf(-3 * Math.PI / 4, -Math.PI / 2, -Math.PI / 4)

        floatingView.post {
            val loc = IntArray(2)
            icon.getLocationOnScreen(loc)
            val iconCenterX = loc[0] + icon.width / 2
            val iconCenterY = loc[1] + icon.height / 2

            for (i in actions.indices) {
                val (iconRes, _, action) = actions[i]
                val button = ImageView(this).apply {
                    setImageResource(iconRes)
                    setBackgroundResource(R.drawable.floating_bg)
                    elevation = 12f
                    setPadding(20, 20, 20, 20)
                }

                val buttonParams = WindowManager.LayoutParams(
                    60,
                    60,
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                    else
                        WindowManager.LayoutParams.TYPE_PHONE,
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                    PixelFormat.TRANSLUCENT
                ).apply {
                    gravity = Gravity.TOP or Gravity.LEFT
                    val angleRad = angles[i]
                    val dx = (radius * cos(angleRad)).toFloat()
                    val dy = (radius * sin(angleRad)).toFloat()
                    x = (iconCenterX + dx - 30).toInt()
                    y = (iconCenterY + dy - 30).toInt()
                }

                button.setOnClickListener {
                    action()
                    closeMenu()
                    isMenuOpen = false
                }

                windowManager.addView(button, buttonParams)
                menuButtons.add(button)
            }
        }
    }

    private fun closeMenu() {
        menuButtons.forEach { button ->
            windowManager.removeView(button)
        }
        menuButtons.clear()
    }

    private fun sendFlutter(method: String) {
        if (::channel.isInitialized) {
            try {
                channel.invokeMethod(method, null)
                Log.d("FloatingIconService", "Invoked Flutter method: $method")
            } catch (e: Exception) {
                Log.e("FloatingIconService", "Error invoking Flutter method $method: $e")
            }
        } else {
            Log.e("FloatingIconService", "Channel not initialized for method: $method")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        closeMenu()
        if (::windowManager.isInitialized && ::floatingView.isInitialized) {
            windowManager.removeView(floatingView)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}