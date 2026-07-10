import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CallLogItem {
  final String name;
  final String phoneNumber;
  final String dateTime;
  final String duration;
  final String callType; // 'outgoing', 'answered', 'missed'
  String? activeTag; // 'Hot leads', 'Follow ups', 'Reminders'

  CallLogItem({
    required this.name,
    required this.phoneNumber,
    required this.dateTime,
    required this.duration,
    required this.callType,
    this.activeTag,
  });
}

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
  String _selectedSIM = 'BSNL Mobile';
  bool _isLoading = false;

  late List<CallLogItem> _callLogs;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _callLogs = [
      CallLogItem(
        name: '+91 7558804685',
        phoneNumber: '+91 7558804685',
        dateTime: 'Jul 8, 9:49 AM',
        duration: '11m 50s',
        callType: 'outgoing',
        activeTag: 'Follow ups',
      ),
      CallLogItem(
        name: '+91 7558804685',
        phoneNumber: '+91 7558804685',
        dateTime: 'Jul 8, 9:48 AM',
        duration: '0m 0s',
        callType: 'answered',
        activeTag: 'Hot leads',
      ),
      CallLogItem(
        name: 'Karshini Plus Two Basics',
        phoneNumber: '+91 9037424448',
        dateTime: 'Jul 8, 8:21 AM',
        duration: '0m 0s',
        callType: 'missed',
        activeTag: 'Reminders',
      ),
      CallLogItem(
        name: '+91 6238445578',
        phoneNumber: '+91 6238445578',
        dateTime: 'Jul 7, 6:46 PM',
        duration: '0m 0s',
        callType: 'missed',
        activeTag: null,
      ),
    ];
  }

  void _simulateRefresh() {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Re-initialize or randomize slightly to simulate a fetch
          _initializeData();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Call logs updated successfully'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _showSIMSelectionDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Text(
                    'Select SIM Card',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.sim_card_outlined, color: AppColors.primary),
              title: const Text('BSNL Mobile'),
              trailing: _selectedSIM == 'BSNL Mobile'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() {
                  _selectedSIM = 'BSNL Mobile';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sim_card_outlined, color: AppColors.primary),
              title: const Text('Jio Mobile'),
              trailing: _selectedSIM == 'Jio Mobile'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() {
                  _selectedSIM = 'Jio Mobile';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sim_card_outlined, color: AppColors.primary),
              title: const Text('Airtel'),
              trailing: _selectedSIM == 'Airtel'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
                  onTap: () {
                    setState(() {
                      _selectedSIM = 'Airtel';
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOptionsMenu(CallLogItem log) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  log.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Call Contact'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.message_outlined),
                title: const Text('Send Message'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete Log', style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() {
                    _callLogs.remove(log);
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Matches Home background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Call Logs',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sim_card_outlined, color: Colors.black87),
            onPressed: _showSIMSelectionDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _simulateRefresh,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Info Banner
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: AppColors.infoBannerBg.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.infoBannerBg),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        children: [
                          const TextSpan(text: 'Showing logs for: '),
                          TextSpan(
                            text: _selectedSIM,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Call logs list or Loader
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _callLogs.length,
                      itemBuilder: (context, index) {
                        final log = _callLogs[index];
                        return _buildCallLogCard(log);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallLogCard(CallLogItem log) {
    // Configure left icon based on call type
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
        iconData = Icons.check;
        break;
      case 'missed':
      default:
        iconBgColor = AppColors.callMissedBg;
        iconColor = AppColors.callMissedIcon;
        iconData = Icons.call_received;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: widget.onLogTap != null ? () => widget.onLogTap!(log) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Call status icon box
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Log Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            log.phoneNumber,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${log.dateTime} • ${log.duration}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Options button
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.black54),
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
                        label: 'Hot leads',
                        icon: Icons.local_fire_department_outlined,
                        defaultColor: AppColors.hotLeads,
                        activeGradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFC2A346), Color(0xFFF44336)],
                        ),
                        log: log,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTagChip(
                        label: 'Follow ups',
                        icon: Icons.sync_alt,
                        defaultColor: AppColors.followUps,
                        activeGradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF0F766E), Color(0xFF2CB3A8)],
                        ),
                        log: log,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTagChip(
                        label: 'Reminders',
                        icon: Icons.access_time_outlined,
                        defaultColor: AppColors.reminders,
                        activeGradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF9D7071), Color(0xFF5D4344)],
                        ),
                        log: log,
                      ),
                    ),
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
    required String label,
    required IconData icon,
    required Color defaultColor,
    required LinearGradient activeGradient,
    required CallLogItem log,
  }) {
    final isSelected = log.activeTag == label;

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            log.activeTag = null; // Toggle off
          } else {
            log.activeTag = label; // Toggle on and automatically deselect others
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: isSelected ? null : Colors.white,
          gradient: isSelected ? activeGradient : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.transparent : defaultColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : defaultColor,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : defaultColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
