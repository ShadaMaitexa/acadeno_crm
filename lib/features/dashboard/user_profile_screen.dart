import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/curve_clippers.dart';
import '../../shared/widgets/logout_icon.dart';
import '../auth/logout_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getUserProfile();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _nameController.text = profile?['name'] as String? ?? '';
      _phoneController.text = profile?['phone'] as String? ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await AuthService.updateCurrentUserProfile(
        name: name,
        phone: _phoneController.text,
      );
      if (!mounted) return;
      setState(() => _profile = {...?_profile, 'name': name, 'phone': _phoneController.text.trim()});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save profile. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _copy(String value) async {
    if (value.trim().isEmpty || value == '—' || value == 'â€”') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to copy')),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  String get _name => _profile?['name'] as String? ?? 'User';
  String get _initial => _name.isEmpty ? 'U' : _name[0].toUpperCase();
  String get _role {
    final role = _profile?['role'] as String? ?? 'User';
    return role.isEmpty ? 'User' : role[0].toUpperCase() + role.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FD),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildHeader(),
                          Transform.translate(
                            offset: const Offset(0, -25),
                            child: Column(
                              children: [
                                _buildAvatar(),
                                const SizedBox(height: 8),
                                Text(_role, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                              ],
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: Column(
                                children: [
                                  _ProfileField(icon: Icons.person_outline, controller: _nameController, hint: 'Name'),
                                  const SizedBox(height: 9),
                                  _ProfileField(icon: Icons.phone_outlined, controller: _phoneController, hint: 'Phone number', keyboardType: TextInputType.phone),
                                  const SizedBox(height: 9),
                                  _ProfileField(icon: Icons.alternate_email, value: _profile?['email'] as String? ?? '—', onCopy: _copy),
                                  const SizedBox(height: 9),
                                  _ProfileField(icon: Icons.key_outlined, value: _profile?['uid'] as String? ?? '—', onCopy: _copy),
                                  const SizedBox(height: 9),
                                  _ProfileField(icon: Icons.business_outlined, value: _profile?['organisation'] as String? ?? 'Acadeno', readOnly: true),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 38,
                                    child: ElevatedButton(
                                      onPressed: _saving ? null : _save,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: const StadiumBorder(),
                                      ),
                                      child: _saving
                                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                          : const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomNavigation(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return ClipPath(
      clipper: TopCurveClipper(),
      child: Container(
        width: double.infinity,
        color: AppColors.primary,
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 58),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 25),
                  tooltip: 'Back to home',
                ),
                IconButton(
                  onPressed: () => showLogoutConfirmationDialog(context),
                  icon: const LogoutIcon(),
                  tooltip: 'Log out',
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text('Hi, $_name', style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() => Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: Text(_initial, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
          Positioned(
            right: -1,
            bottom: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: const Color(0xFF16B85B), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
            ),
          ),
        ],
      );

  Widget _buildBottomNavigation() => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', onTap: () => Navigator.of(context).pop()),
            _NavItem(icon: Icons.phone_outlined, label: 'Call logs', onTap: () => Navigator.of(context).pop()),
            _NavItem(icon: Icons.home_outlined, label: 'Home', active: true, onTap: () => Navigator.of(context).pop()),
            _NavItem(icon: Icons.task_alt_outlined, label: 'Tasks', onTap: () => Navigator.of(context).pop()),
            _NavItem(icon: Icons.location_on_outlined, label: 'Visits', onTap: () => Navigator.of(context).pop()),
          ],
        ),
      );
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.icon, this.controller, this.value, this.hint, this.onCopy, this.keyboardType, this.readOnly = false});

  final IconData icon;
  final TextEditingController? controller;
  final String? value;
  final String? hint;
  final void Function(String)? onCopy;
  final TextInputType? keyboardType;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final text = value ?? '';
    return Container(
      height: 31,
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.textDark),
          const SizedBox(width: 9),
          Expanded(
            child: controller != null
                ? TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: const TextStyle(fontSize: 10, color: AppColors.textDark),
                    decoration: InputDecoration(border: InputBorder.none, hintText: hint, isDense: true),
                  )
                : Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.textDark)),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: () => onCopy!(text),
              icon: const Icon(Icons.copy_outlined, size: 14),
              splashRadius: 18,
              color: AppColors.textDark,
              tooltip: 'Copy',
            ),
          if (readOnly) const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.onTap, this.active = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 48,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: active ? AppColors.primary : Colors.grey.shade500),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 7, color: active ? AppColors.primary : Colors.grey.shade600)),
            ],
          ),
        ),
      );

}
