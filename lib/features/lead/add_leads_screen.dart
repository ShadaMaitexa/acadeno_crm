import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/lead_service.dart';

class AddLeadsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const AddLeadsScreen({super.key, required this.onBack});

  @override
  State<AddLeadsScreen> createState() => _AddLeadsScreenState();
}

class _AddLeadsScreenState extends State<AddLeadsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();
  String _avatarLetter = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      final text = _nameController.text.trim();
      final newLetter = text.isNotEmpty ? text[0].toUpperCase() : '';
      if (_avatarLetter != newLetter) {
        setState(() => _avatarLetter = newLetter);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await LeadService.addLead(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        notes: _noteController.text,
        type: 'hot',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Lead added successfully!'),
              backgroundColor: Colors.green),
        );
        widget.onBack();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: widget.onBack,
        ),
        title: Text(
          'Add leads',
          style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor, shape: BoxShape.circle),
                    child: _avatarLetter.isNotEmpty
                        ? Center(
                            child: Text(
                              _avatarLetter,
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        : Icon(Icons.person_outline,
                            size: 48, color: Theme.of(context).iconTheme.color?.withOpacity(0.3)),
                  ),
                ),
                const SizedBox(height: 32),
                _buildField(
                  controller: _nameController,
                  icon: Icons.person_outline,
                  hint: 'Name',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  hint: 'Phone',
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Phone is required';
                    if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) return 'Enter a valid 10-digit number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _emailController,
                  icon: Icons.alternate_email,
                  hint: 'Email (Optional)',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                        return 'Enter a valid email';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _noteController,
                    maxLines: 5,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 80),
                        child: Icon(Icons.description_outlined,
                            color: Colors.black54),
                      ),
                      hintText: 'Enter additional notes (optional)',
                      hintStyle:
                          TextStyle(color: Colors.black54, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Text('Save',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
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
        keyboardType: keyboardType,
        style: const TextStyle(fontWeight: FontWeight.w600),
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
          hintText: hint,
          hintStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
