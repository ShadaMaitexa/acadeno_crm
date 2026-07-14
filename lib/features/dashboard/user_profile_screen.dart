import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/curve_clippers.dart';
import '../auth/logout_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _loadProfile();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getUserProfile();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loading = false;
    });
    _animController.forward();
  }

  String get _initial {
    final name = _profile?['name'] as String? ?? '';
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get _displayName => _profile?['name'] as String? ?? 'User';

  String _formatTimestamp(dynamic ts) {
    if (ts == null) return '—';
    try {
      // Firestore Timestamp
      final dt = (ts as dynamic).toDate() as DateTime;
      return '${dt.day.toString().padLeft(2, '0')} / '
          '${dt.month.toString().padLeft(2, '0')} / '
          '${dt.year}';
    } catch (_) {
      return ts.toString();
    }
  }

  String _capitalise(String? val) {
    if (val == null || val.isEmpty) return '—';
    return val[0].toUpperCase() + val.substring(1);
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return const Color(0xFF2E7D32);
      case 'offline':
        return Colors.grey.shade500;
      default:
        return Colors.grey.shade400;
    }
  }

  Color _statusBg(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return const Color(0xFFE8F5E9);
      case 'offline':
        return Colors.grey.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  void _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // ── Curved header ──────────────────────────────────────────
                ClipPath(
                  clipper: TopCurveClipper(),
                  child: Container(
                    color: AppColors.primary,
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      bottom: 52,
                      left: 24,
                      right: 24,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Logo badge
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  'a',
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Georgia',
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  showLogoutConfirmationDialog(context),
                              child: const Icon(Icons.exit_to_app,
                                  color: Colors.white, size: 28),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Hi, $_displayName',
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

                // ── Avatar overlapping header ───────────────────────────────
                Transform.translate(
                  offset: const Offset(0, -32),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.12),
                        child: Text(
                          _initial,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Scrollable content ──────────────────────────────────────
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                        child: Column(
                          children: [
                            // Role + status chips
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _RoleChip(
                                    label: _capitalise(
                                        _profile?['role'] as String?)),
                                const SizedBox(width: 8),
                                _StatusChip(
                                  label: _capitalise(
                                      _profile?['status'] as String?),
                                  color: _statusColor(
                                      _profile?['status'] as String?),
                                  bg: _statusBg(
                                      _profile?['status'] as String?),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // ── Info card ───────────────────────────────────
                            _SectionCard(
                              title: 'Personal Information',
                              children: [
                                _InfoRow(
                                  icon: Icons.person_outline,
                                  label: 'Full Name',
                                  value: _profile?['name'] as String? ?? '—',
                                ),
                                _InfoRow(
                                  icon: Icons.alternate_email_rounded,
                                  label: 'Email',
                                  value: _profile?['email'] as String? ?? '—',
                                ),
                                _InfoRow(
                                  icon: Icons.phone_outlined,
                                  label: 'Phone',
                                  value: _profile?['phone'] as String? ?? '—',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── Account card ────────────────────────────────
                            _SectionCard(
                              title: 'Account Details',
                              children: [
                                _InfoRow(
                                  icon: Icons.badge_outlined,
                                  label: 'Role',
                                  value:
                                      _capitalise(_profile?['role'] as String?),
                                ),
                                _InfoRow(
                                  icon: Icons.circle_outlined,
                                  label: 'Status',
                                  value: _capitalise(
                                      _profile?['status'] as String?),
                                  valueColor: _statusColor(
                                      _profile?['status'] as String?),
                                ),
                                _InfoRow(
                                  icon: Icons.calendar_today_outlined,
                                  label: 'Joined',
                                  value: _formatTimestamp(
                                      _profile?['createdAt']),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── UID card with copy ───────────────────────────
                            _SectionCard(
                              title: 'User ID',
                              children: [
                                _UidRow(
                                  uid: _profile?['uid'] as String? ?? '—',
                                  onCopy: () => _copyToClipboard(
                                      _profile?['uid'] as String? ?? ''),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  final String label;
  const _RoleChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _StatusChip(
      {required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F3F7)),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UidRow extends StatelessWidget {
  final String uid;
  final VoidCallback onCopy;
  const _UidRow({required this.uid, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fingerprint_outlined,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              uid,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textLight,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onCopy,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.copy_rounded,
                  color: AppColors.primary, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
