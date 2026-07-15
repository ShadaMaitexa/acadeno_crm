import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/lead_service.dart';
import '../../shared/widgets/app_ui_widgets.dart';
import '../../shared/widgets/curve_clippers.dart';
import '../auth/logout_screen.dart';
import '../call_log/call_logs_screen.dart';
import '../call_log/call_details_screen.dart';
import '../lead/hot_leads_screen.dart';
import '../lead/add_leads_screen.dart';
import 'user_profile_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 2;
  bool _showHotLeads = false;
  bool _showAddLead = false;
  String _userName = 'User';
  int _hotLeadsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final profile = await AuthService.getUserProfile();
    if (mounted && profile != null) {
      setState(() {
        _userName = profile['name'] as String? ?? 'User';
      });
    }
  }

  void _logout() {
    showLogoutConfirmationDialog(context);
  }

  Widget _buildPlaceholder(String title) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 8),
            Text('Coming Soon',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeBody() {
    return Column(
      children: [
        ClipPath(
          clipper: TopCurveClipper(),
          child: Container(
            color: AppColors.primary,
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 48,
              left: 24,
              right: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Open drawer or do nothing if logo is tapped
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Georgia',
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _logout,
                      child: const Icon(Icons.exit_to_app,
                          color: Colors.white, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Hi, $_userName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: LeadService.leadsStream(type: 'hot'),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;
              if (count != _hotLeadsCount && mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _hotLeadsCount = count);
                });
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  HomeMenuCard(
                    title: 'Hot leads',
                    subtitle: 'Prospects ready to close',
                    icon: Icons.local_fire_department,
                    iconColor: AppColors.hotLeads,
                    iconBg: const Color(0xFFFFF0E6),
                    badgeCount: count > 0 ? count : null,
                    isActive: _showHotLeads, // Highlight when pressed before transition
                    onTap: () {
                      setState(() => _showHotLeads = true);
                    },
                  ),
                  HomeMenuCard(
                    title: 'Follow ups',
                    subtitle: 'Leads waiting on a replay',
                    icon: Icons.person_outline,
                    iconColor: AppColors.followUps,
                    iconBg: const Color(0xFFE6F7F5),
                    onTap: () {},
                  ),
                  HomeMenuCard(
                    title: 'Reminders',
                    subtitle: 'Tasks and callbacks due soon',
                    icon: Icons.access_time,
                    iconColor: AppColors.reminders,
                    iconBg: const Color(0xFFF3EBE9),
                    onTap: () {},
                  ),
                  HomeMenuCard(
                    title: 'College visits',
                    subtitle: 'Scheduled campus visits',
                    icon: Icons.account_balance,
                    iconColor: const Color(0xFF37474F),
                    iconBg: const Color(0xFFECEFF1),
                    onTap: () {},
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  CallLogItem? _selectedLog;

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildPlaceholder('Dashboard');
      case 1:
        if (_selectedLog != null) {
          return CallDetailsScreen(
            log: _selectedLog!,
            onBack: () => setState(() => _selectedLog = null),
          );
        }
        return CallLogsScreen(
          onBack: () => setState(() => _currentIndex = 2),
          onLogTap: (log) => setState(() => _selectedLog = log),
        );
      case 2:
        if (_showAddLead) {
          return AddLeadsScreen(
            onBack: () => setState(() => _showAddLead = false),
          );
        }
        if (_showHotLeads) {
          return HotLeadsScreen(
            onBack: () => setState(() => _showHotLeads = false),
            onAdd: () => setState(() => _showAddLead = true),
          );
        }
        return _buildHomeBody();
      case 3:
        return _buildPlaceholder('Tasks');
      case 4:
        return const UserProfileScreen();
      default:
        return _buildHomeBody();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              if (index == 1) {
                _selectedLog = null;
              }
              if (index == 2) {
                _showHotLeads = false;
                _showAddLead = false;
                _selectedLog = null;
              }
            });
          },
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.phone_outlined), label: 'Call logs'),
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.task_alt_outlined), label: 'Tasks'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }
}
