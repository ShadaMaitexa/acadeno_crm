import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
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
  bool _isConverted = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Call details',
          style: TextStyle(
            color: Colors.black87,
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
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                      widget.log.phoneNumber,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.log.phoneNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          widget.log.dateTime.toUpperCase(),
                          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          widget.log.duration,
                          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
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
                            label: const Text('Call', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF0FDF4),
                              foregroundColor: const Color(0xFF16A34A),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.message, size: 18), // A simple chat icon for WhatsApp
                            label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  color: Colors.white,
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
                    Icon(
                      _isConverted ? Icons.check_circle_outline : Icons.remove_circle_outline,
                      color: _isConverted ? Colors.green : Colors.grey,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deal Status',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _isConverted ? 'CONVERTED' : 'UNCONVERTED',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _isConverted ? Colors.black87 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Switch(
                      value: _isConverted,
                      activeThumbColor: Colors.white,
                      activeTrackColor: Colors.green,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey.shade400,
                      onChanged: (value) {
                        setState(() {
                          _isConverted = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Notes Card
              Container(
                height: 120,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: Icon(Icons.insert_drive_file_outlined, color: Colors.black54, size: 24),
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
                      borderRadius: BorderRadius.circular(12),
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
