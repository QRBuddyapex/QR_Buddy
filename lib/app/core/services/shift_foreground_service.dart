import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ShiftHandler());
}

class ShiftHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('Shift foreground service started at $timestamp via ${starter.name}');
    // Send initial data to main (e.g., for UI sync)
    FlutterForegroundTask.sendDataToMain({'event': 'shift_active', 'timestamp': timestamp.millisecondsSinceEpoch});
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Periodic task: e.g., log or poll backend (avoid heavy ops)
    print('Shift repeat event at $timestamp');
    // Send data to main for any UI updates
    FlutterForegroundTask.sendDataToMain({
      'event': 'heartbeat',
      'timestamp': timestamp.millisecondsSinceEpoch,
    });
    // Optionally update notification here (but prefer from main for status sync)
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print('Shift foreground service destroyed at $timestamp (timeout: $isTimeout)');
    // Send destroy event to main
    FlutterForegroundTask.sendDataToMain({'event': 'shift_ended', 'timestamp': timestamp.millisecondsSinceEpoch});
  }

  @override
  void onButtonPressed(String id) {
    print('Notification button pressed: $id');
    switch (id) {
      case 'break_shift':
        // Send to main to trigger BREAK (since can't access controller here)
        FlutterForegroundTask.sendDataToMain({'event': 'take_break'});
        break;
      case 'end_shift':
        // Stop service directly
        FlutterForegroundTask.stopService();
        break;
    }
  }

  @override
  void onNotificationPressed() {
    print('Notification tapped - app will reopen via initialRoute');
    // Handled by plugin (opens at notificationInitialRoute)
  }

  @override
  void onReceiveData(Object data) {
    print('Received data in handler: $data');
    // Handle incoming data from main (e.g., status updates), but minimal for now
  }
}