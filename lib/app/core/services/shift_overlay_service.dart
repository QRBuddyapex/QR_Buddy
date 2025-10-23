import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

@pragma('vm:entry-point')
void overlayMain() {
  runApp(const OverlayApp());
}

class OverlayApp extends StatelessWidget {
  const OverlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          onTap: () async {
            await FlutterOverlayWindow.closeOverlay();
            await LaunchApp.openApp(
              androidPackageName: 'com.nxtdesigns.qrbuddy_v2',
              openStore: false,
            );
          },
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  )
                ],
              ),
              child: const Icon(Icons.delivery_dining, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
