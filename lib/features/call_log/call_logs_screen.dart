import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/call_log_service.dart';
import '../../core/services/device_call_log_service.dart';

String _extractCallLogNumber(CallLogEntry entry) {
  final dynamic dynamicEntry = entry;
  return (dynamicEntry.number as String?) ??
      (dynamicEntry.formattedNumber as String?) ??
      '';
}

String _extractCallLogType(CallLogEntry entry) {
  final dynamic dynamicEntry = entry;
  return DeviceCallLogService.mapCallType(
      (dynamicEntry.callType ?? dynamicEntry.type) as dynamic);
}

// ─── Data Model ──────────────────────────────────────────────────────────────

class CallLogItem {
  final String id; // Firestore doc id (empty for device-only logs)
  final String name;
  final String phoneNumber;
  final String dateTime;
  final String duration;
  final String callType; // 'outgoing' | 'answered' | 'missed'
  String? activeTag;

  CallLogItem({
    this.id = '',
    required this.name,
    required this.phoneNumber,
    required this.dateTime,
    required this.duration,
    required this.callType,
    this.activeTag,
  });

  factory CallLogItem.fromDevice(CallLogEntry e, {String? savedTag}) {
    final phoneNumber = _extractCallLogNumber(e);
    return CallLogItem(
      id: '', // no Firestore id yet
      name: 'Unknown',
      phoneNumber: phoneNumber,
      dateTime: DeviceCallLogService.formatTimestamp(e.timestamp),
      duration: DeviceCallLogService.formatDuration(e.duration),
      callType: _extractCallLogType(e),
      activeTag: savedTag,
    );
  }
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class CallLogsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(CallLogItem)? onLogTap;

  const CallLogsScreen({
    super.key,
    required this.onBack,
    this.onLogTap,
  });

  @override
  State<CallLogsScreen> createState() => _CallLogsScreenState();
}

class _CallLogsScreenState extends State<CallLogsScreen> {
  String _selectedSIM = 'SIM 1';
  CallLogPermissionStatus _permStatus = CallLogPermissionStatus.unknown;
  bool _loadingLogs = false;
  List<CallLogItem> _deviceLogs = [];

  // Phone → saved tag from Firestore (keyed by phone number)
  final Map<String, String?> _tagCache = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final status = await DeviceCallLogService.checkPermission();
    if (mounted) setState(() => _permStatus = status);

    // If already granted, load immediately
    if (status == CallLogPermissionStatus.granted) {
      _loadDeviceLogs();
    }
  }

  Future<void> _requestPermission() async {
    final status = await DeviceCallLogService.requestPermission();
    if (mounted) setState(() => _permStatus = status);
    if (status == CallLogPermissionStatus.granted) {
      _loadDeviceLogs();
    }
  }

  Future<void> _loadDeviceLogs() async {
    if (mounted) setState(() => _loadingLogs = true);

    final entries = await DeviceCallLogService.getCallLogs();

   
    final items = entries.map((e) {
      final phone = _extractCallLogNumber(e);
      return CallLogItem.fromDevice(e, savedTag: _tagCache[phone]);
    }).toList();
    if (mounted) {
      setState(() {
        _deviceLogs = items;
        _loadingLogs = false;
      });
    }
  }

  Future<void> _updateTag(CallLogItem log, String? newTag) async {
    // Optimistic UI update
    setState(() => log.activeTag = newTag);

    // If the log already has a Firestore ID, update in place
    if (log.id.isNotEmpty) {
      await CallLogService.updateTag(log.id, newTag);
      return;
    }

    // Otherwise: save the full call log to Firestore first, then update the tag
    final docId = await CallLogService.addCallLog(
      name: log.name,
      phone: log.phoneNumber,
      dateTime: log.dateTime,
      duration: log.duration,
      callType: log.callType,
      tag: newTag,
    );

    // Cache the tag by phone number for future loads
    _tagCache[log.phoneNumber] = newTag;

    // Update the log object with the new Firestore id (mutate via setState)
    final idx = _deviceLogs.indexOf(log);
    if (idx != -1 && mounted) {
      setState(() {
        _deviceLogs[idx] = CallLogItem(
          id: docId,
          name: log.name,
          phoneNumber: log.phoneNumber,
          dateTime: log.dateTime,
          duration: log.duration,
          callType: log.callType,
          activeTag: newTag,
        );
      });
    }
  }

  // ─── Dialogs ───────────────────────────────────────────────────────────────

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 32),
              ),
              const SizedBox(height: 24),
              const Text(
                'Clear Call History?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to permanently delete all call records?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Implement delete
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Delete',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Keep History',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSIMSelectionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select SIM for calling',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildSIMOption(ctx, 'SIM 1 (BSNL)', 'BSNL', '+91 7558004685'),
              const SizedBox(height: 12),
              _buildSIMOption(ctx, 'SIM 2 (Airtel)', 'Airtel', '+91 9308004875'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSIMOption(BuildContext ctx, String label, String network, String phone) {
    final isSelected = _selectedSIM == label.split(' ')[0] + ' ' + label.split(' ')[1];
    return GestureDetector(
      onTap: () {
        setState(() => _selectedSIM = label.split(' ')[0] + ' ' + label.split(' ')[1]);
        Navigator.pop(ctx);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.sim_card_outlined,
                color: isSelected ? AppColors.primary : Colors.grey.shade500),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark)),
                  Text(phone,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.signal_cellular_alt,
                color: isSelected ? AppColors.primary : Colors.grey.shade400,
                size: 20),
          ],
        ),
      ),
    );
  }

  // ─── Options Menu ──────────────────────────────────────────────────────────

  void _showOptionsMenu(CallLogItem log) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(log.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(ctx);
                if (widget.onLogTap != null) widget.onLogTap!(log);
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call Contact'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.message_outlined),
              title: const Text('Send Message'),
              onTap: () => Navigator.pop(ctx),
            ),
            if (log.id.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete Log',
                    style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await CallLogService.deleteLog(log.id);
                  setState(() => _deviceLogs.remove(log));
                },
              ),
          ],
        ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: widget.onBack,
        ),
        title: Text('Call Logs',
            style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        actions: [
          if (_permStatus == CallLogPermissionStatus.granted)
            IconButton(
              icon: Icon(Icons.sim_card_outlined, color: Theme.of(context).iconTheme.color),
              onPressed: _showSIMSelectionDialog,
            ),
          if (_permStatus == CallLogPermissionStatus.granted)
            IconButton(
              icon: Icon(Icons.refresh, color: Theme.of(context).iconTheme.color),
              onPressed: _loadDeviceLogs,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    // ── Web / iOS ────────────────────────────────────────────────────────────
    if (_permStatus == CallLogPermissionStatus.unsupported) {
      return _buildUnsupportedState();
    }

    // ── Permission not yet asked ─────────────────────────────────────────────
    if (_permStatus == CallLogPermissionStatus.unknown) {
      return _buildPermissionRequest();
    }

    // ── Permanently denied ───────────────────────────────────────────────────
    if (_permStatus == CallLogPermissionStatus.permanentlyDenied) {
      return _buildPermanentlyDenied();
    }

    // ── Denied (can ask again) ───────────────────────────────────────────────
    if (_permStatus == CallLogPermissionStatus.denied) {
      return _buildDeniedState();
    }

    // ── Granted ──────────────────────────────────────────────────────────────
    return Column(
      children: [
        // SIM info banner
        Container(
          width: double.infinity,
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.infoBannerBg.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.infoBannerBg),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color),
                    children: [
                      const TextSpan(text: 'Showing logs for: '),
                      TextSpan(
                        text: _selectedSIM,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Select All Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: false,
                      onChanged: (v) {},
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Select All',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              GestureDetector(
                onTap: _showClearHistoryDialog,
                child: Icon(Icons.delete_outline, color: Colors.red.shade400),
              ),
            ],
          ),
        ),

        // Log list
        Expanded(
          child: _loadingLogs
              ? const Center(
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary)))
              : _deviceLogs.isEmpty
                  ? _buildEmptyLogs()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _deviceLogs.length,
                      itemBuilder: (context, index) =>
                          _buildCallLogCard(_deviceLogs[index]),
                    ),
        ),
      ],
    );
  }

  // ─── State Widgets ──────────────────────────────────────────────────────────

  Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_outlined,
                  size: 50, color: AppColors.primary),
            ),
           SizedBox(height: 32),
            Text(
              'Access Call History',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Acadeno CRM needs permission to read your phone\'s call history so it can display your call logs and let you tag them.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _requestPermission,
                icon:
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text('Allow Access',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 3,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onBack,
              child:
                  const Text('Not now', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeniedState() {
    return Center(
      child: Padding(
        padding:EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_locked_outlined,
                  size: 50, color: Colors.orange),
            ),
            const SizedBox(height: 32),
            Text(
              'Permission Denied',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 12),
            Text(
              'Call history access was denied. Please allow the permission to view your call logs.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _requestPermission,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Try Again',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermanentlyDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.block_outlined, size: 50, color: Colors.red),
            ),
            const SizedBox(height: 32),
            Text(
              'Permission Blocked',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 12),
            Text(
              'Call history access has been permanently denied. Please enable it manually from your device settings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: DeviceCallLogService.openSettings,
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                label: const Text('Open Settings',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnsupportedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smartphone, size: 50, color: Colors.blue),
            ),
            const SizedBox(height: 32),
            Text(
              'Android Only Feature',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              kIsWeb
                  ? 'Reading device call logs is not supported in the web browser. Please use the Android app to access this feature.'
                  : 'Reading device call logs is only supported on Android devices.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyLogs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.phone_missed, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No Call Logs Found',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _loadDeviceLogs,
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            label: const Text('Refresh',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  // ─── Call Log Card ──────────────────────────────────────────────────────────

  Widget _buildCallLogCard(CallLogItem log) {
    Color iconBgColor;
    Color iconColor;
    IconData iconData;

    switch (log.callType) {
      case 'outgoing':
        iconBgColor = AppColors.callOutgoingBg;
        iconColor = AppColors.callOutgoingIcon;
        iconData = Icons.call_made;
        break;
      case 'answered':
        iconBgColor = AppColors.callAnsweredBg;
        iconColor = AppColors.callAnsweredIcon;
        iconData = Icons.call_received;
        break;
      case 'missed':
      default:
        iconBgColor = AppColors.callMissedBg;
        iconColor = AppColors.callMissedIcon;
        iconData = Icons.call_missed;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: widget.onLogTap != null ? () => widget.onLogTap!(log) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: false,
                        onChanged: (v) {},
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                          child: Icon(iconData, color: iconColor, size: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(log.name,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyLarge?.color),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(log.phoneNumber,
                              style: TextStyle(
                                  fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color)),
                          const SizedBox(height: 4),
                          Text(
                              '${log.dateTime}${log.duration.isNotEmpty && log.duration != '0m 0s' ? ' • ${log.duration}' : ''}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showOptionsMenu(log),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Tag chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: _buildTagChip(
                            log: log,
                            label: 'Hot leads',
                            icon: Icons.local_fire_department_outlined,
                            defaultColor: AppColors.hotLeads,
                            activeGradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFC2A346), Color(0xFFF44336)],
                            ))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildTagChip(
                            log: log,
                            label: 'Follow ups',
                            icon: Icons.sync_alt,
                            defaultColor: AppColors.followUps,
                            activeGradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF0F766E), Color(0xFF2CB3A8)],
                            ))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildTagChip(
                            log: log,
                            label: 'Reminders',
                            icon: Icons.access_time_outlined,
                            defaultColor: AppColors.reminders,
                            activeGradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF9D7071), Color(0xFF5D4344)],
                            ))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagChip({
    required CallLogItem log,
    required String label,
    required IconData icon,
    required Color defaultColor,
    required LinearGradient activeGradient,
  }) {
    final isSelected = log.activeTag == label;

    return InkWell(
      onTap: () => _updateTag(log, isSelected ? null : label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? null : Theme.of(context).cardColor,
          gradient: isSelected ? activeGradient : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : defaultColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 14, color: isSelected ? Colors.white : defaultColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : defaultColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
