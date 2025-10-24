import 'package:flutter/services.dart';

class NativeShiftService {
  static const _channel = MethodChannel('com.nxtdesigns.qrbuddy_v2/shift_service');

  static Future<void> startShift() async => _channel.invokeMethod('startShift');
  static Future<void> takeBreak() async => _channel.invokeMethod('takeBreak');
  static Future<void> resumeShift() async => _channel.invokeMethod('resumeShift');
  static Future<void> endShift() async => _channel.invokeMethod('endShift');
}
