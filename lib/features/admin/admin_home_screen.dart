import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/admin_service.dart';
import '../../core/services/role_service.dart';
import '../../shared/widgets/curve_clippers.dart';
import '../auth/logout_screen.dart';
import 'admin_profile_screen.dart';
import 'labels_screen.dart';
import 'roles_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  int _staffCount = 0;

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    Widget? suffix,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FA),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.black),
          filled: true,
          fillColor: const Color(0xFFEAF1FA),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          prefixIcon:
              icon != null ? Icon(icon, size: 20, color: Colors.black) : null,
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ─── Add User Dialog ────────────────────────────────────────────────────────

  void _showAddUserDialog() async {
    final roles = await RoleService.getRoleNames();
    if (!mounted) return;

    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String? selectedRole = roles.isNotEmpty ? roles.first : null;
    bool loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add New User',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color)),
                        InkWell(
                            onTap: () => Navigator.pop(ctx),
                            child: const Icon(Icons.close, size: 20)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDialogTextField(
                      controller: nameCtrl,
                      hintText: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Name is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDialogTextField(
                      controller: emailCtrl,
                      hintText: 'Email Address',
                      icon: Icons.alternate_email_rounded,
                      suffix: IconButton(
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: emailCtrl.text));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Email copied'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy_outlined,
                            color: Colors.black, size: 20),
                        splashRadius: 20,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Email is required';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(v.trim())) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDialogTextField(
                      controller: phoneCtrl,
                      hintText: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Phone is required';
                        if (!RegExp(r'^\d{10}$').hasMatch(v.trim()))
                          return 'Enter a valid 10-digit number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDialogTextField(
                      controller: passCtrl,
                      hintText: 'Password',
                      icon: Icons.lock_outline,
                      suffix: IconButton(
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: passCtrl.text));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password copied'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy_outlined,
                            color: Colors.black, size: 20),
                        splashRadius: 20,
                      ),
                      obscureText: true,
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Min 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    if (roles.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: const Text(
                          '⚠️ No roles found. Please add roles from the Roles tab first.',
                          style:
                              TextStyle(fontSize: 13, color: Colors.deepOrange),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF1FA),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedRole,
                          decoration: InputDecoration(
                            hintText: 'Select Role',
                            filled: true,
                            fillColor: Color(0xFFEAF1FA),
                            prefixIcon: Icon(Icons.badge_outlined,
                                color: Colors.black, size: 20),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: roles
                              .map((r) =>
                                  DropdownMenuItem(value: r, child: Text(r)))
                              .toList(),
                          onChanged: (v) => selectedRole = v,
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: loading
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              if (roles.isEmpty) return;
                              setDialogState(() => loading = true);
                              try {
                                await AdminService.addUser(
                                  name: nameCtrl.text,
                                  email: emailCtrl.text,
                                  phone: phoneCtrl.text,
                                  password: passCtrl.text,
                                  role: selectedRole!,
                                );
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('User added successfully'),
                                        backgroundColor: Colors.green),
                                  );
                                }
                              } catch (e) {
                                setDialogState(() => loading = false);
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                        content: Text('Error: $e'),
                                        backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Add User',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Edit User Dialog ───────────────────────────────────────────────────────

  void _showEditUserDialog(Map<String, dynamic> data) async {
    final roles = await RoleService.getRoleNames();
    if (!mounted) return;

    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: data['name'] ?? '');
    final emailCtrl = TextEditingController(text: data['email'] ?? '');
    final phoneCtrl = TextEditingController(text: data['phone'] ?? '');
    final passCtrl = TextEditingController(text: data['password'] ?? '');
    String? selectedRole = data['role'];
    if (roles.isNotEmpty && !roles.contains(selectedRole)) {
      selectedRole = roles.first;
    }
    bool loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Edit User',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color)),
                        InkWell(
                            onTap: () => Navigator.pop(ctx),
                            child: const Icon(Icons.close, size: 20)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDialogTextField(
                      controller: nameCtrl,
                      hintText: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Name is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDialogTextField(
                      controller: emailCtrl,
                      hintText: 'Email Address',
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      suffix: IconButton(
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: emailCtrl.text));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Email copied'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy_outlined,
                            color: Colors.black, size: 20),
                        splashRadius: 20,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Email is required';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(v.trim())) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDialogTextField(
                      controller: phoneCtrl,
                      hintText: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Phone is required';
                        if (!RegExp(r'^\d{10}$').hasMatch(v.trim()))
                          return 'Enter a valid 10-digit number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDialogTextField(
                      controller: passCtrl,
                      hintText: 'Password',
                      icon: Icons.lock_outline,
                      suffix: IconButton(
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: passCtrl.text));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password copied'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy_outlined,
                            color: Colors.black, size: 20),
                        splashRadius: 20,
                      ),
                      obscureText: true,
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Min 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    if (roles.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF1FA),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedRole,
                          decoration: InputDecoration(
                            hintText: 'Select Role',
                            filled: true,
                            fillColor: const Color(0xFFEAF1FA),
                            prefixIcon: const Icon(Icons.badge_outlined,
                                color: Colors.black, size: 20),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: roles
                              .map((r) =>
                                  DropdownMenuItem(value: r, child: Text(r)))
                              .toList(),
                          onChanged: (v) => selectedRole = v,
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: loading
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setDialogState(() => loading = true);
                              try {
                                await AdminService.updateUser(
                                  uid: data['uid'] as String,
                                  name: nameCtrl.text,
                                  email: emailCtrl.text,
                                  phone: phoneCtrl.text,
                                  role: selectedRole!,
                                );
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('User updated'),
                                        backgroundColor: Colors.green),
                                  );
                                }
                              } catch (e) {
                                setDialogState(() => loading = false);
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                        content: Text('Error: $e'),
                                        backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Update User',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Logout ─────────────────────────────────────────────────────────────────

  void _logout() {
    showLogoutConfirmationDialog(context);
  }

  // ─── Staff List Tab ─────────────────────────────────────────────────────────

  Widget _buildStaffTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: AdminService.staffStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary)));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final docs = snapshot.data?.docs ?? [];
        final total = docs.length;
        final active = docs.where((d) => d.data()['status'] == 'active').length;
        final offline =
            docs.where((d) => d.data()['status'] == 'offline').length;
        if (_staffCount != total) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _staffCount = total);
          });
        }

        return Column(
          children: [
            // Header with curve
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipPath(
                  clipper: TopCurveClipper(),
                  child: Container(
                    color: AppColors.primary,
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      bottom: 70,
                      left: 24,
                      right: 24,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AdminProfileScreen(),
                                  ),
                                );
                              },
                              child: const Icon(Icons.account_circle_outlined,
                                  color: Colors.white, size: 28),
                            ),
                            GestureDetector(
                              onTap: _logout,
                              child: const Icon(Icons.exit_to_app,
                                  color: Colors.white, size: 28),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Hi, Admin',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  left: 24,
                  right: 24,
                  child: Row(
                    children: [
                      Expanded(
                          child:
                              _buildStatCard(total.toString(), 'Total Staff')),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _buildStatCard(
                              active.toString(), 'Active', Colors.green)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _buildStatCard(
                              offline.toString(), 'Offline', Colors.orange)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Expanded(
              child: docs.isEmpty
                  ? _buildEmptyStaff()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data();
                        return _buildStaffCard(data);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String value, String label, [Color? dotColor]) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration:
                      BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
              ],
              Text(value,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStaffCard(Map<String, dynamic> data) {
    final name = data['name'] as String? ?? 'Unknown';
    final role = data['role'] as String? ?? '';
    final email = data['email'] as String? ?? '';
    final status = data['status'] as String? ?? 'active';
    final uid = data['uid'] as String? ?? '';
    final isOnline = status == 'active';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                child: Text(initial,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                const SizedBox(height: 2),
                Text(role,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                Text(email,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) async {
              if (value == 'edit') {
                _showEditUserDialog(data);
              } else if (value == 'deactivate') {
                await AdminService.deactivateUser(uid);
              } else if (value == 'activate') {
                await AdminService.activateUser(uid);
              } else if (value == 'delete') {
                await AdminService.deleteUser(uid);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('User deleted'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(LucideIcons.pencil,
                      size: 18, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  const Text('Edit'),
                ]),
              ),
              PopupMenuItem(
                value: isOnline ? 'deactivate' : 'activate',
                child: Row(children: [
                  Icon(
                    isOnline ? LucideIcons.ban : LucideIcons.checkCircle,
                    size: 18,
                    color: isOnline ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(isOnline ? 'Deactivate' : 'Activate'),
                ]),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStaff() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/Background.png',
            height: 250,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text('No Team Members\nFound',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Your staff list is empty. Ready to bring your team on board?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddUserDialog,
            icon: const Icon(Icons.person_add_alt_1,
                color: Colors.white, size: 18),
            label: const Text('Add New User',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildStaffTab(),
      RolesScreen(onLogout: _logout),
      const LabelsScreen(),
      _buildPlaceholder('Analytics'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _currentIndex == 0 && _staffCount > 0
          ? FloatingActionButton(
              onPressed: _showAddUserDialog,
              backgroundColor: AppColors.primary,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: ClipPath(
        clipper: BottomNavCurveClipper(),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 12),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.groups_outlined), label: 'Staff'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.badge_outlined), label: 'Roles'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.label_outline), label: 'Labels'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.insights), label: 'Analytics'),
            ],
          ),
        ),
      ),
      body: tabs[_currentIndex],
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_outlined,
              size: 64, color: AppColors.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('$title\n(Coming Soon)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Clippers moved to shared/widgets/curve_clippers.dart
