import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

enum CallLogPermissionStatus {
  unknown,
  granted,
  denied,
  permanentlyDenied,
  unsupported, // web / iOS
}

/// Lightweight model matching the data returned from the native MethodChannel.
class CallLogEntry {
  final String number;
  final String name;
  final String date;
  final String duration;
  final String type; // 'outgoing' | 'answered' | 'missed'
  final int timestamp;

  const CallLogEntry({
    required this.number,
    required this.name,
    required this.date,
    required this.duration,
    required this.type,
    required this.timestamp,
  });

  factory CallLogEntry.fromMap(Map<dynamic, dynamic> m) => CallLogEntry(
        number: m['number'] as String? ?? '',
        name: m['name'] as String? ?? '',
        date: m['date'] as String? ?? '',
        duration: m['duration'] as String? ?? '',
        type: m['type'] as String? ?? 'outgoing',
        timestamp: (m['timestamp'] as int?) ?? 0,
      );
}

class DeviceCallLogService {
  static const _channel = MethodChannel('com.acadeno.crm/call_logs');

  /// Returns the current permission status without requesting.
  static Future<CallLogPermissionStatus> checkPermission() async {
    if (kIsWeb) return CallLogPermissionStatus.unsupported;
    if (defaultTargetPlatform != TargetPlatform.android) {
      return CallLogPermissionStatus.unsupported;
    }
    final status = await Permission.phone.status;
    return _mapStatus(status);
  }

  /// Requests READ_CALL_LOG permission and returns the result.
  static Future<CallLogPermissionStatus> requestPermission() async {
    if (kIsWeb) return CallLogPermissionStatus.unsupported;
    if (defaultTargetPlatform != TargetPlatform.android) {
      return CallLogPermissionStatus.unsupported;
    }
    final status = await Permission.phone.request();
    return _mapStatus(status);
  }

  /// Opens app settings so the user can manually grant permission.
  static Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Reads call logs from the device via a native MethodChannel.
  /// Returns an empty list on unsupported platforms.
  static Future<List<CallLogEntry>> getCallLogs() async {
    if (kIsWeb) return [];
    if (defaultTargetPlatform != TargetPlatform.android) return [];

    try {
      final List<dynamic> raw =
          await _channel.invokeMethod('getCallLogs');
      return raw
          .cast<Map<dynamic, dynamic>>()
          .map(CallLogEntry.fromMap)
          .toList();
    } on PlatformException catch (_) {
      return [];
    }
  }

  static CallLogPermissionStatus _mapStatus(PermissionStatus status) {
    if (status.isGranted) return CallLogPermissionStatus.granted;
    if (status.isPermanentlyDenied) {
      return CallLogPermissionStatus.permanentlyDenied;
    }
    return CallLogPermissionStatus.denied;
  }

  /// Maps the string type to the app's internal string type (already correct).
  static String mapCallType(String type) => type;

  /// Duration is already formatted by the native side.
  static String formatDuration(String duration) => duration;

  /// Date is already formatted by the native side.
  static String formatTimestamp(String date) => date;
}
