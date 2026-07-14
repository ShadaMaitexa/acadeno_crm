import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/lead_service.dart';
import '../../shared/widgets/app_ui_widgets.dart';

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
            backgroundColor: Colors.green,
          ),
        );
        widget.onBack();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
        backgroundColor: Theme.of(context).cardColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: widget.onBack,
        ),
        title: Text(
          'Add leads',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: _avatarLetter.isNotEmpty
                        ? Center(
                            child: Text(
                              _avatarLetter,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const Icon(Icons.person,
                            size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 28),
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
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Phone is required';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) {
                      return 'Enter a valid 10-digit number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                buildFormField(
                  context: context,
                  controller: _emailController,
                  hint: 'Email',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                buildFormField(
                  context: context,
                  controller: _noteController,
                  hint: 'Enter additional notes (optional)',
                  icon: Icons.notes_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                buildPrimaryButton(
                  label: 'Save',
                  loading: _loading,
                  onPressed: _save,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
