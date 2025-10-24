package com.nxtdesigns.qrbuddy_v2

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.*
import android.widget.ImageView
import androidx.core.view.isVisible
import io.flutter.plugin.common.MethodChannel
import kotlin.math.cos
import kotlin.math.sin

class FloatingIconService : Service() {

    private lateinit var windowManager: WindowManager
    private lateinit var floatingView: View
    private lateinit var icon: ImageView
    private var isMenuOpen = false
    private val menuButtons = mutableListOf<ImageView>()
    private val radius = 220 // distance from main icon

    private lateinit var channel: MethodChannel

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        val layoutParams = WindowManager.LayoutParams(
            150,
            150,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )
        layoutParams.gravity = Gravity.CENTER_VERTICAL or Gravity.END
        layoutParams.x = 20
        layoutParams.y = 0

        floatingView = LayoutInflater.from(this).inflate(R.layout.overlay_icon, null)
        icon = floatingView.findViewById(R.id.floating_icon)

        // TODO: Assign MethodChannel via MainActivity
        // channel = MethodChannel(...)

        icon.setOnClickListener { toggleMenu() }

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

        for (i in actions.indices) {
            val (iconRes, _, action) = actions[i]
            val button = ImageView(this).apply {
                setImageResource(iconRes)
                setBackgroundResource(R.drawable.floating_bg)
                elevation = 12f
                val params = ViewGroup.LayoutParams(100, 100)
                layoutParams = params
                setOnClickListener {
                    action()
                    closeMenu()
                    isMenuOpen = false
                }
            }
            menuButtons.add(button)
            floatingView.post {
                floatingView.parent?.let {
                    (floatingView.parent as ViewGroup).addView(button)
                    button.x = floatingView.x + (radius * cos(angles[i])).toFloat()
                    button.y = floatingView.y + (radius * sin(angles[i])).toFloat()
                }
            }
        }
    }

    private fun closeMenu() {
        menuButtons.forEach { button ->
            (floatingView.parent as ViewGroup).removeView(button)
        }
        menuButtons.clear()
    }

    private fun sendFlutter(method: String) {
        if (::channel.isInitialized) channel.invokeMethod(method, null)
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
