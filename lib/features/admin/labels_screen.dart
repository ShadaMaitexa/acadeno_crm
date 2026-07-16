import 'package:acadeno_crm/features/auth/logout_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/label_service.dart';
import '../../shared/widgets/curve_clippers.dart';
import '../../shared/widgets/logout_icon.dart';
import 'admin_profile_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LabelsScreen extends StatefulWidget {
  const LabelsScreen({super.key});

  @override
  State<LabelsScreen> createState() => _LabelsScreenState();
}

class _LabelsScreenState extends State<LabelsScreen> {
  final _labelController = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _addLabel() async {
    final text = _labelController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isAdding = true);
    try {
      await LabelService.addLabel(name: text, description: '');
      _labelController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  Future<void> _deleteLabel(String id) async {
    try {
      await LabelService.deleteLabel(id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: LabelService.labelsStream(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Curved blue header (same pattern as Staff / Roles) ─────────
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Blue clipped background
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: ClipPath(
                      clipper: TopCurveClipper(),
                      child: Container(
                        color: AppColors.primary,
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 16,
                          bottom: 72,
                          left: 24,
                          right: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Top row: profile  |  logout
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AdminProfileScreen(),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                      Icons.account_circle_outlined,
                                      color: Colors.white,
                                      size: 28),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      showLogoutConfirmationDialog(context),
                                  child: const LogoutIcon(size: 28),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Greeting
                            const Text(
                              'Hi, Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Add-label row floating over the curve bottom
                  Positioned(
                    bottom: 0,
                    left: 24,
                    right: 24,
                    child: Row(
                      children: [
                        // Text field
                        Expanded(
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _labelController,
                              onSubmitted: (_) => _addLabel(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1A2E),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Add Label',
                                hintStyle: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 16),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // + button
                        GestureDetector(
                          onTap: _isAdding ? null : _addLabel,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: _isAdding
                                ? const Padding(
                                    padding: EdgeInsets.all(13.0),
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Icon(Icons.add,
                                    color: Colors.white, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Space to clear the overlapping input row
              const SizedBox(height: 14),

              // ── Section title row ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACTIVE LABELS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (docs.isNotEmpty)
                      Text(
                        'TOTAL  ${docs.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ── List / empty state ────────────────────────────────────────
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      )
                    : snapshot.hasError
                        ? Center(child: Text('Error: ${snapshot.error}'))
                        : docs.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  final doc = docs[index];
                                  final data = doc.data();
                                  final labelName =
                                      data['name'] as String? ?? 'Unnamed';
                                  return _buildLabelCard(doc.id, labelName);
                                },
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Label card ───────────────────────────────────────────────────────────────

  Widget _buildLabelCard(String id, String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Folder icon container
          Icon(Icons.label, color: AppColors.primary, size: 20),

          const SizedBox(width: 14),

          // Label name
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),

          // Delete icon
          GestureDetector(
            onTap: () => _deleteLabel(id),
            child: SizedBox(
              width: 34,
              height: 34,
              child: Center(
                child: Icon(LucideIcons.trash2,
                    color: Colors.red.shade400, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.label_off_outlined,
                size: 40, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          const Text(
            'No labels found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first status label to get started.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
