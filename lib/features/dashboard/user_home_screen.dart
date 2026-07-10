import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../call_log/call_logs_screen.dart';
import '../call_log/call_details_screen.dart';
import '../lead/hot_leads_screen.dart';
import '../lead/add_leads_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 2; // Home selected
  bool _showHotLeads = false;
  bool _showAddLead = false;
  String _selectedCard = 'Follow ups';

  Widget _buildPlaceholder(String title) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              title == 'Dashboard'
                  ? Icons.grid_view
                  : title == 'Tasks'
                      ? Icons.task_alt_outlined
                      : Icons.location_on_outlined,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '$title Screen\n(Coming Soon)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeBody() {
    return Column(
      children: [
        // Top section with blue background and curve
        ClipPath(
          clipper: _CurveClipper(),
          child: Container(
            color: AppColors.primary,
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 50, // Space for the curve
              left: 24,
              right: 24,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.emoji_emotions_outlined, color: Colors.white, size: 28),
                    const Icon(Icons.exit_to_app, color: Colors.white, size: 28),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Hi, Sameesha',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Cards List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              _buildCard(
                title: 'Hot leads',
                subtitle: 'Prospects ready to close',
                iconData: Icons.local_fire_department_outlined,
                iconColor: Colors.redAccent,
                isSelected: _selectedCard == 'Hot leads',
                onTap: () {
                  setState(() {
                    _selectedCard = 'Hot leads';
                    // Delaying navigation slightly allows the user to see the border change before transitioning
                    Future.delayed(const Duration(milliseconds: 150), () {
                      if (mounted) {
                        setState(() {
                          _showHotLeads = true;
                        });
                      }
                    });
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildCard(
                title: 'Follow ups',
                subtitle: 'Leads waiting on a replay',
                iconData: Icons.person_outline,
                iconColor: AppColors.primary,
                isSelected: _selectedCard == 'Follow ups',
                onTap: () {
                  setState(() {
                    _selectedCard = 'Follow ups';
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildCard(
                title: 'Reminders',
                subtitle: 'Task and callbacks due soon',
                iconData: Icons.access_time,
                iconColor: Colors.brown.shade400,
                isSelected: _selectedCard == 'Reminders',
                onTap: () {
                  setState(() {
                    _selectedCard = 'Reminders';
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildCard(
                title: 'College visits',
                subtitle: 'Scheduled campus visits',
                iconData: Icons.account_balance_outlined,
                iconColor: Colors.blueGrey.shade800,
                isSelected: _selectedCard == 'College visits',
                onTap: () {
                  setState(() {
                    _selectedCard = 'College visits';
                  });
                },
              ),
              const SizedBox(height: 24),
            ],
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
            onBack: () {
              setState(() {
                _selectedLog = null;
              });
            },
          );
        }
        return CallLogsScreen(
          onBack: () {
            setState(() {
              _currentIndex = 2; // Home
            });
          },
          onLogTap: (log) {
            setState(() {
              _selectedLog = log;
            });
          },
        );
      case 2:
        if (_showAddLead) {
          return AddLeadsScreen(
            onBack: () {
              setState(() {
                _showAddLead = false;
              });
            },
          );
        }
        if (_showHotLeads) {
          return HotLeadsScreen(
            onBack: () {
              setState(() {
                _showHotLeads = false;
              });
            },
            onAdd: () {
              setState(() {
                _showAddLead = true;
              });
            },
          );
        }
        return _buildHomeBody();
      case 3:
        return _buildPlaceholder('Tasks');
      case 4:
        return _buildPlaceholder('Visits');
      default:
        return _buildHomeBody();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Light background for the list
      bottomNavigationBar: ClipPath(
        clipper: _BottomNavClipper(),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 12), // Prevent clipping the icons
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.layoutGrid),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.phoneCall),
                label: 'Call logs',
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.listTodo),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.mapPin),
                label: 'Visits',
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData iconData,
    required Color iconColor,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Icon(
            iconData,
            color: iconColor,
            size: 32,
          ),
        ],
      ),
      ),
    );
  }
}

class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    // Control point and end point for quadratic bezier curve
    path.quadraticBezierTo(
      size.width / 2, size.height + 20,
      size.width, size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _BottomNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 15);
    // Quadratic bezier to curve upward in the middle
    path.quadraticBezierTo(
      size.width / 2, -10,
      size.width, 15,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
