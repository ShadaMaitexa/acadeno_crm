import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/lead_service.dart';
import '../../core/services/call_log_service.dart';
import '../../core/services/device_call_log_service.dart';
import 'call_logs_screen.dart';

class CallDetailsScreen extends StatefulWidget {
  final CallLogItem log;
  final VoidCallback onBack;

  const CallDetailsScreen({
    super.key,
    required this.log,
    required this.onBack,
  });

  @override
  State<CallDetailsScreen> createState() => _CallDetailsScreenState();
}

class _CallDetailsScreenState extends State<CallDetailsScreen> {
  late bool _isConverted;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialise from the log's existing converted flag if it came from Firestore
    _isConverted = widget.log.isConverted ?? false;
    _notesController.text = widget.log.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _openContactAction(bool whatsapp) async {
    final opened = whatsapp
        ? await DeviceCallLogService.openWhatsApp(widget.log.phoneNumber)
        : await DeviceCallLogService.openDialer(widget.log.phoneNumber);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(whatsapp
            ? 'Unable to open WhatsApp for this number.'
            : 'Unable to open the phone dialer.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine icon based on call type, matching the main list
    Color iconBgColor;
    Color iconColor;
    IconData iconData;

    switch (widget.log.callType) {
      case 'outgoing':
        iconBgColor = AppColors.callOutgoingBg;
        iconColor = AppColors.callOutgoingIcon;
        iconData = Icons.call_made;
        break;
      case 'answered':
        iconBgColor = AppColors.callAnsweredBg;
        iconColor = AppColors.callAnsweredIcon;
        iconData = Icons.check;
        break;
      case 'missed':
      default:
        iconBgColor = AppColors.callMissedBg;
        iconColor = AppColors.callMissedIcon;
        iconData = Icons.call_received;
        break;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: widget.onBack,
        ),
        title: Text(
          'Call details',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Main Info Card
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          color: iconColor,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.log.name.isNotEmpty && widget.log.name != 'Unknown'
                          ? widget.log.name
                          : widget.log.phoneNumber,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.log.phoneNumber,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          widget.log.dateTime.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.timer_outlined,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          widget.log.duration,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openContactAction(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEFF6FF),
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.phone, size: 18),
                            label: const Text('Call',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openContactAction(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF0FDF4),
                              foregroundColor: const Color(0xFF16A34A),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.message,
                                size: 18), // A simple chat icon for WhatsApp
                            label: const Text('WhatsApp',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Deal Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _isConverted ? Colors.green : Colors.grey,
                            width: 1.5),
                      ),
                      child: Icon(
                        _isConverted
                            ? Icons.check
                            : Icons
                                .horizontal_rule, // Using a dash/line for unconverted
                        color: _isConverted ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _isConverted ? 'CONVERTED' : 'UNCONVERTED',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _isConverted
                            ? Colors.black87
                            : Colors.grey.shade600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _isConverted,
                      activeThumbColor: Colors.white,
                      activeTrackColor: Colors.green,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey.shade400,
                      onChanged: (value) async {
                        final previousValue = _isConverted;
                        setState(() => _isConverted = value);
                        try {
                          if (widget.log.isLead) {
                            await LeadService.updateLead(
                              widget.log.id,
                              {'converted': value},
                            );
                          } else if (widget.log.id.isNotEmpty) {
                            await CallLogService.updateConverted(
                              widget.log.id,
                              value,
                            );
                          } else {
                            widget.log.id = await CallLogService.addCallLog(
                              name: widget.log.name,
                              phone: widget.log.phoneNumber,
                              dateTime: widget.log.dateTime,
                              duration: widget.log.duration,
                              callType: widget.log.callType,
                              tag: widget.log.activeTag,
                              converted: value,
                              deviceLogKey: CallLogService.deviceLogKey(
                                phone: widget.log.phoneNumber,
                                timestamp: widget.log.timestamp,
                                duration: widget.log.duration,
                                callType: widget.log.callType,
                              ),
                            );
                          }
                          widget.log.isConverted = value;
                        } catch (_) {
                          if (!mounted) return;
                          setState(() => _isConverted = previousValue);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Unable to save conversion status.'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Notes Card
              Container(
                height: 120,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Icon(Icons.insert_drive_file_outlined,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              ?.withOpacity(0.5),
                          size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _notesController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Enter additional notes(optional)',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.black38,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(top: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back or perform save action
                    widget.onBack();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
