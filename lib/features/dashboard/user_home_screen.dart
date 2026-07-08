import 'package:flutter/material.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 2; // Home selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F1F8), // Light background for the list
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
            selectedItemColor: const Color(0xFF3582CB),
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.phone_in_talk_outlined),
                label: 'Call logs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.task_alt_outlined),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on_outlined),
                label: 'Visits',
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Top section with blue background and curve
          ClipPath(
            clipper: _CurveClipper(),
            child: Container(
              color: const Color(0xFF3582CB),
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
                      const Icon(Icons.account_circle_outlined, color: Colors.white, size: 28),
                      const Icon(Icons.logout, color: Colors.white, size: 28),
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
                ),
                const SizedBox(height: 16),
                _buildCard(
                  title: 'Follow ups',
                  subtitle: 'Leads waiting on a replay',
                  iconData: Icons.person_outline,
                  iconColor: const Color(0xFF3582CB),
                  isSelected: true,
                ),
                const SizedBox(height: 16),
                _buildCard(
                  title: 'Reminders',
                  subtitle: 'Task and callbacks due soon',
                  iconData: Icons.access_time,
                  iconColor: Colors.brown.shade400,
                ),
                const SizedBox(height: 16),
                _buildCard(
                  title: 'College visits',
                  subtitle: 'Scheduled campus visits',
                  iconData: Icons.account_balance_outlined,
                  iconColor: Colors.blueGrey.shade800,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData iconData,
    required Color iconColor,
    bool isSelected = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: const Color(0xFF3582CB), width: 2)
            : Border.all(color: Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
