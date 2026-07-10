import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AddLeadsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const AddLeadsScreen({super.key, required this.onBack});

  @override
  State<AddLeadsScreen> createState() => _AddLeadsScreenState();
}

class _AddLeadsScreenState extends State<AddLeadsScreen> {
  final _nameController = TextEditingController(text: 'Sameesha');
  final _phoneController = TextEditingController(text: '+91 8084455854');
  final _emailController = TextEditingController(text: 'Sameesha@gmail.com');
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Add leads',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Avatar
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Name Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline, color: Colors.black54),
                    hintText: 'Name',
                    hintStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Phone Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone_outlined, color: Colors.black54),
                    hintText: 'Phone',
                    hintStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Email Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.alternate_email, color: Colors.black54),
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Note Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _noteController,
                  maxLines: 5,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  decoration: const InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 80.0), // Align to top
                      child: Icon(Icons.description_outlined, color: Colors.black54),
                    ),
                    hintText: 'Enter additional notes (optional)',
                    hintStyle: TextStyle(color: Colors.black54, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Save Button
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

