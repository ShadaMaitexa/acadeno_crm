import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../auth/login_screen.dart';
import '../call_log/call_logs_screen.dart';
import '../call_log/call_details_screen.dart';
import '../lead/hot_leads_screen.dart';
import '../lead/add_leads_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 2; // Home selected
  bool _showHotLeads = false;
  bool _showAddLead = false;
  String _selectedCard = 'Follow ups';
  String _userName = 'Hi';

  late AnimationController _headerAnim;
  late AnimationController _cardsAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _cardsAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic));

    _headerAnim.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardsAnim.forward();
    });

    _loadUserName();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _cardsAnim.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final profile = await AuthService.getUserProfile();
    if (mounted && profile != null) {
      setState(() {
        _userName = profile['name'] as String? ?? 'Hi';
      });
    }
  }

  void _logout() async {
    await AuthService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

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
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                title == 'Dashboard'
                    ? Icons.grid_view
                    : title == 'Tasks'
                        ? Icons.task_alt_outlined
                        : Icons.location_on_outlined,
                size: 40,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coming Soon',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeBody() {
    return Column(
      children: [
        // ── Animated Header ──────────────────────────────────────────────────
        FadeTransition(
          opacity: _headerFade,
          child: SlideTransition(
            position: _headerSlide,
            child: ClipPath(
              clipper: _CurveClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2563B0), Color(0xFF3582CB)],
                  ),
                ),
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  bottom: 56,
                  left: 24,
                  right: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.emoji_emotions_outlined,
                              color: Colors.white, size: 22),
                        ),
                        GestureDetector(
                          onTap: _logout,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.exit_to_app,
                                color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Hi, $_userName 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'What would you like to do today?',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.80),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Animated Cards ───────────────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            children: [
              _buildAnimatedCard(
                index: 0,
                title: 'Hot Leads',
                subtitle: 'Prospects ready to close',
                iconData: Icons.local_fire_department_outlined,
                iconColor: Colors.deepOrange,
                iconBg: const Color(0xFFFFEDE5),
                isSelected: _selectedCard == 'Hot leads',
                onTap: () {
                  setState(() {
                    _selectedCard = 'Hot leads';
                    Future.delayed(const Duration(milliseconds: 150), () {
                      if (mounted) setState(() => _showHotLeads = true);
                    });
                  });
                },
              ),
              _buildAnimatedCard(
                index: 1,
                title: 'Follow Ups',
                subtitle: 'Leads waiting on a reply',
                iconData: Icons.person_outline,
                iconColor: AppColors.primary,
                iconBg: const Color(0xFFE6F1FB),
                isSelected: _selectedCard == 'Follow ups',
                onTap: () => setState(() => _selectedCard = 'Follow ups'),
              ),
              _buildAnimatedCard(
                index: 2,
                title: 'Reminders',
                subtitle: 'Tasks and callbacks due soon',
                iconData: Icons.access_time_rounded,
                iconColor: const Color(0xFF7E5C54),
                iconBg: const Color(0xFFF3EBE9),
                isSelected: _selectedCard == 'Reminders',
                onTap: () => setState(() => _selectedCard = 'Reminders'),
              ),
              _buildAnimatedCard(
                index: 3,
                title: 'College Visits',
                subtitle: 'Scheduled campus visits',
                iconData: Icons.account_balance_outlined,
                iconColor: const Color(0xFF37474F),
                iconBg: const Color(0xFFECEFF1),
                isSelected: _selectedCard == 'College visits',
                onTap: () => setState(() => _selectedCard = 'College visits'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData iconData,
    required Color iconColor,
    required Color iconBg,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return AnimatedBuilder(
      animation: _cardsAnim,
      builder: (context, child) {
        final delay = index * 0.15;
        final t = (((_cardsAnim.value - delay) / (1.0 - delay)).clamp(0.0, 1.0));
        final curved = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: curved,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - curved)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: isSelected ? 16 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(iconData,
                    color: isSelected ? AppColors.primary : iconColor,
                    size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.primary : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: isSelected ? 0 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isSelected ? AppColors.primary : Colors.black26,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
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
              _currentIndex = 2;
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
      backgroundColor: AppColors.background,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                if (index == 2) {
                  _showHotLeads = false;
                  _showAddLead = false;
                  _selectedLog = null;
                }
              });
            },
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w400, fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(LucideIcons.layoutGrid), label: 'Dashboard'),
              BottomNavigationBarItem(
                  icon: Icon(LucideIcons.phoneCall), label: 'Call logs'),
              BottomNavigationBarItem(
                  icon: Icon(LucideIcons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(LucideIcons.listTodo), label: 'Tasks'),
              BottomNavigationBarItem(
                  icon: Icon(LucideIcons.mapPin), label: 'Visits'),
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _buildBody(),
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
    path.quadraticBezierTo(
        size.width / 2, size.height + 20, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
