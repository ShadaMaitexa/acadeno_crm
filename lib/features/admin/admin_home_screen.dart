import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/admin_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/role_service.dart';
import '../auth/login_screen.dart';
import 'roles_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
        filled: true,
        fillColor: const Color(0xFFEFF6FF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.black38) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
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
                        const Text('Add New User',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildDialogTextField(
                      controller: emailCtrl,
                      hintText: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildDialogTextField(
                      controller: phoneCtrl,
                      hintText: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildDialogTextField(
                      controller: passCtrl,
                      hintText: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (v) =>
                          (v == null || v.length < 6) ? 'Min 6 characters' : null,
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
                          style: TextStyle(fontSize: 13, color: Colors.deepOrange),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: selectedRole,
                        decoration: InputDecoration(
                          hintText: 'Select Role',
                          filled: true,
                          fillColor: const Color(0xFFEFF6FF),
                          prefixIcon: const Icon(Icons.badge_outlined,
                              color: Colors.black38, size: 20),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: roles
                            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (v) => selectedRole = v,
                        validator: (v) => v == null ? 'Required' : null,
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
                                        content: Text('User added successfully'),
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
                                  fontWeight: FontWeight.bold, color: Colors.white)),
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
    String? selectedRole = data['role'];
    if (roles.isNotEmpty && !roles.contains(selectedRole)) {
      selectedRole = roles.first;
    }
    bool loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
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
                        const Text('Edit User',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildDialogTextField(
                      controller: emailCtrl,
                      hintText: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildDialogTextField(
                      controller: phoneCtrl,
                      hintText: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    if (roles.isNotEmpty)
                      DropdownButtonFormField<String>(
                        initialValue: selectedRole,
                        decoration: InputDecoration(
                          hintText: 'Select Role',
                          filled: true,
                          fillColor: const Color(0xFFEFF6FF),
                          prefixIcon: const Icon(Icons.badge_outlined,
                              color: Colors.black38, size: 20),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: roles
                            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (v) => selectedRole = v,
                        validator: (v) => v == null ? 'Required' : null,
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
                                  fontWeight: FontWeight.bold, color: Colors.white)),
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

  // ─── Staff List Tab ─────────────────────────────────────────────────────────

  Widget _buildStaffTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: AdminService.staffStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final docs = snapshot.data?.docs ?? [];
        final total = docs.length;
        final active = docs.where((d) => d.data()['status'] == 'active').length;
        final offline = docs.where((d) => d.data()['status'] == 'offline').length;

        return Column(
          children: [
            // Header with curve
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipPath(
                  clipper: _CurveClipper(),
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
                            const Icon(Icons.account_circle_outlined,
                                color: Colors.white, size: 28),
                            GestureDetector(
                              onTap: _logout,
                              child: const Icon(Icons.exit_to_app,
                                  color: Colors.white, size: 28),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Hii Admin',
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard(total.toString(), 'Total Staff', Colors.blue),
                      _buildStatCard(active.toString(), 'Active', Colors.green),
                      _buildStatCard(offline.toString(), 'Offline', Colors.red),
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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

  Widget _buildStatCard(String value, String label, Color dotColor) {
    return Container(
      width: (MediaQuery.of(context).size.width - 80) / 3,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
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
        color: Colors.white,
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
                    color: isOnline ? Colors.green : Colors.red,
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
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87)),
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
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
                  Icon(LucideIcons.pencil, size: 18, color: Colors.blue.shade600),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.group_off_outlined, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 24),
        const Text('No Team Members\nFound',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 8),
        Text(
          'Your staff list is empty. Add a new member\nto your team record!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _showAddUserDialog,
          icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 18),
          label: const Text('Add New User',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ],
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildStaffTab(),
      RolesScreen(onLogout: _logout),
      _buildPlaceholder('Labels'),
      _buildPlaceholder('Analytics'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _showAddUserDialog,
              backgroundColor: AppColors.primary,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: ClipPath(
        clipper: _BottomNavClipper(),
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
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('$title\n(Coming Soon)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ─── Clippers ────────────────────────────────────────────────────────────────

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

class _BottomNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 15);
    path.quadraticBezierTo(size.width / 2, -10, size.width, 15);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
