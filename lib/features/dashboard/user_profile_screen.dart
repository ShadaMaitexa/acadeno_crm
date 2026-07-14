import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/admin_service.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/app_ui_widgets.dart';
import '../../shared/widgets/curve_clippers.dart';
import '../auth/logout_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String _uid = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getUserProfile();
    if (!mounted) return;
    _uid = AuthService.currentUser?.uid ?? '';
    _nameController.text = profile?['name'] as String? ?? '';
    _emailController.text = profile?['email'] as String? ?? '';
    _phoneController.text = profile?['phone'] as String? ?? '';
    _role = profile?['role'] as String? ?? '';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _uid.isEmpty) return;
    setState(() => _saving = true);
    try {
      await AdminService.updateUser(
        uid: _uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _role,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String get _initial {
    final name = _nameController.text.trim();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
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
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {}, // Optional drawer
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    'a',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Georgia',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => showLogoutConfirmationDialog(context),
                              child: const Icon(Icons.exit_to_app,
                                  color: Colors.white, size: 28),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Hi, ${_nameController.text.isNotEmpty ? _nameController.text : "User"}',
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
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          _initial,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          buildFormField(
                            context: context,
                            controller: _nameController,
                            hint: 'Name',
                            icon: Icons.person_outline,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Name is required'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          buildFormField(
                            context: context,
                            controller: _phoneController,
                            hint: 'Phone',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 14),
                          buildFormField(
                            context: context,
                            controller: _emailController,
                            hint: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),
                          buildFormField(
                            context: context,
                            controller: TextEditingController(text: 'someID'), // Example ID
                            hint: 'ID',
                            icon: Icons.key_outlined,
                            enabled: false,
                          ),
                          const SizedBox(height: 14),
                          buildFormField(
                            context: context,
                            controller: TextEditingController(text: 'Acadeno'), // Company
                            hint: 'Company',
                            icon: Icons.business_outlined,
                            enabled: false,
                          ),
                          const SizedBox(height: 32),
                          buildPrimaryButton(
                            label: 'Save',
                            loading: _saving,
                            onPressed: _save,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
