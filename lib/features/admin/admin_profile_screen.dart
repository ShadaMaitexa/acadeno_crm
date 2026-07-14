import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/admin_service.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/app_ui_widgets.dart';
import '../../shared/widgets/curve_clippers.dart';
import '../auth/logout_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _emailController = TextEditingController(text: 'admin@acadeno.in');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _loading = true;
  bool _saving = false;
  String _role = 'admin';
  String _uid = '';
  String _displayName = 'Admin';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getUserProfile();
    if (!mounted) return;
    _uid = AuthService.currentUser?.uid ?? '';
    _displayName = profile?['name'] as String? ?? 'Admin';
    _emailController.text = profile?['email'] as String? ?? 'admin@acadeno.in';
    _role = profile?['role'] as String? ?? 'admin';
    setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    if (_uid.isEmpty) return;
    setState(() => _saving = true);
    try {
      await AdminService.updateUser(
        uid: _uid,
        name: _displayName,
        email: _emailController.text.trim(),
        phone: '',
        role: _role,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Unable to save profile: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _copy(String text) async {
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
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    // Header height so the card can overlap it correctly
    final statusBarH = MediaQuery.of(context).padding.top;
    const headerPaddingBottom = 72.0; // extra so card overlaps nicely

    return SingleChildScrollView(
        child: Column(
      children: [
        // ── Curved blue header ──────────────────────────────────────────────
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipPath(
              clipper: TopCurveClipper(),
              child: Container(
                color: AppColors.primary,
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: statusBarH + 16,
                  bottom: headerPaddingBottom,
                  left: 24,
                  right: 24,
                ),
                child: Column(
                  children: [
                    // Top row: person icon | logout icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.account_circle_outlined,
                            color: Colors.white, size: 28),
                        GestureDetector(
                          onTap: () => showLogoutConfirmationDialog(context),
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── White card overlapping the header ───────────────────────────
            Positioned(
              top: 180,
              left: 20,
              right: 20,
              child: _buildCard(),
            ),
          ],
        ),

        // Space for the card overflow
        const SizedBox(height: 120),

        // ── Save button below card ──────────────────────────────────────────
      ],
    ));
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 64,
              color: Color(0xFFB0C4DE),
            ),
          ),
          const SizedBox(height: 24),

          // Email field
          _buildInfoField(
            icon: Icons.alternate_email_rounded,
            controller: _emailController,
            onCopy: () => _copy(_emailController.text),
          ),
          const SizedBox(height: 14),

          // Password field (read-only display)
          _buildInfoField(
            icon: Icons.key_outlined,
            controller: _passwordController,
            obscure: false,
            onCopy: () => _copy(_passwordController.text),
          ),
          const SizedBox(height: 24),
          buildPrimaryButton(
            label: 'Save',
            loading: _saving,
            onPressed: _saveProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required TextEditingController controller,
    required VoidCallback onCopy,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFEAF1FA),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(icon, color: Colors.black, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: true,
              obscureText: obscure,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                filled: true,
                fillColor: Color(0xFFEAF1FA),
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          GestureDetector(
            onTap: onCopy,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: const Icon(Icons.copy_outlined,
                  color: Colors.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
