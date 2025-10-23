// shift_foreground_service.dart

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/routes/routes.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ShiftHandler());
}

class ShiftHandler extends TaskHandler {
  final TokenStorage _tokenStorage = TokenStorage();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('Shift foreground service started at $timestamp via ${starter.name}');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // This is a periodic heartbeat. Can be used for location tracking or logging.
    // print('Shift repeat event at $timestamp');
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print('Shift foreground service destroyed at $timestamp (timeout: $isTimeout)');
    FlutterForegroundTask.sendDataToMain({'event': 'shift_ended'});
  }

  @override
  void onButtonPressed(String id) async {
    print('Notification button pressed: $id');
    const String dashboardRoute = RoutesName.ticketDashboardView;

    switch (id) {
      case 'take_break':
        // MODIFIED: Update the buttons to show "Resume Shift" after taking a break.
        await FlutterForegroundTask.updateService(
          notificationText: 'On Break - Waiting for orders...',
          notificationButtons: [
            const NotificationButton(id: 'resume_shift', text: 'Resume Shift'),
            const NotificationButton(id: 'end_shift', text: 'End Shift'),
          ],
        );
        await _tokenStorage.savePendingShiftStatus('BREAK');
        FlutterForegroundTask.launchApp(dashboardRoute);
        FlutterForegroundTask.sendDataToMain({'event': 'take_break'});
        break;

      case 'resume_shift':
        // MODIFIED: Update the buttons back to "Take Break" after resuming.
        await FlutterForegroundTask.updateService(
          notificationText: 'Waiting for orders...',
          notificationButtons: [
            const NotificationButton(id: 'take_break', text: 'Take Break'),
            const NotificationButton(id: 'end_shift', text: 'End Shift'),
          ],
        );
        await _tokenStorage.savePendingShiftStatus('START');
        FlutterForegroundTask.launchApp(dashboardRoute);
        FlutterForegroundTask.sendDataToMain({'event': 'resume_shift'});
        break;

      case 'end_shift':
        await _tokenStorage.savePendingShiftStatus('END');
        // Let the main app stop the service once the API call is confirmed.
        // This ensures the service doesn't stop prematurely if the API fails.
        FlutterForegroundTask.launchApp(dashboardRoute);
        FlutterForegroundTask.sendDataToMain({'event': 'end_shift'});
        // We let the ShiftController stop the service after successful API update
        // FlutterForegroundTask.stopService();
        break;
    }
  }

  @override
  void onNotificationPressed() {
    // This brings the app to the foreground. The plugin handles this.
    print('Notification tapped - app will reopen via initialRoute');
  }

  @override
  void onReceiveData(Object data) {
    // Not used in this direction, but required to be implemented.
  }
}