import 'package:flutter/foundation.dart';
import '../../shared/helpers/date_helpers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:call_log/call_log.dart';

enum CallLogPermissionStatus {
  unknown,
  granted,
  denied,
  permanentlyDenied,
  unsupported, // web / iOS
}


class DeviceCallLogService {
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

  /// Reads call logs from the device.
  /// Returns an empty list on unsupported platforms.
  static Future<List<CallLogEntry>> getCallLogs() async {
    if (kIsWeb) return [];
    if (defaultTargetPlatform != TargetPlatform.android) return [];

    final entries = await CallLog.get();
    return entries.toList();
  }

  static CallLogPermissionStatus _mapStatus(PermissionStatus status) {
    if (status.isGranted) return CallLogPermissionStatus.granted;
    if (status.isPermanentlyDenied) return CallLogPermissionStatus.permanentlyDenied;
    return CallLogPermissionStatus.denied;
  }

  /// Maps call_log's CallType to the app's internal string type
  static String mapCallType(CallType? type) {
    switch (type) {
      case CallType.outgoing:
        return 'outgoing';
      case CallType.incoming:
        return 'answered';
      case CallType.missed:
        return 'missed';
      case CallType.rejected:
        return 'missed';
      default:
        return 'outgoing';
    }
  }

  /// Formats duration in seconds to "Xm Ys"
  static String formatDuration(int? seconds) {
    return DateHelpers.formatDuration(seconds);
  }

  /// Formats a unix timestamp (ms) to a readable string
  static String formatTimestamp(int? timestamp) {
    return DateHelpers.formatTimestamp(timestamp);
  }
}
