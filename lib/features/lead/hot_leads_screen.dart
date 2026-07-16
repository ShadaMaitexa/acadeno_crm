import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/lead_service.dart';
import '../call_log/call_logs_screen.dart';
import '../call_log/call_details_screen.dart';
import 'add_leads_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HotLeadsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final String leadType;
  final String title;

  const HotLeadsScreen({
    super.key,
    required this.onBack,
    this.leadType = 'hot',
    this.title = 'Hot leads',
  });

  @override
  State<HotLeadsScreen> createState() => _HotLeadsScreenState();
}

class _HotLeadsScreenState extends State<HotLeadsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _selectionMode = false;
  final Set<String> _selectedLeadIds = {};

  // When non-null, show CallDetailsScreen for this lead
  CallLogItem? _selectedLead;
  bool _showAddLeadForm = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteSelectedLeads() async {
    final ids = _selectedLeadIds.toList();
    if (ids.isEmpty) return;
    try {
      await Future.wait(ids.map(LeadService.deleteLead));
      if (mounted) {
        setState(() {
          _selectedLeadIds.clear();
          _selectionMode = false;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete selected leads. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show call details if a lead is selected
    if (_selectedLead != null) {
      return CallDetailsScreen(
        log: _selectedLead!,
        onBack: () => setState(() => _selectedLead = null),
      );
    }

    if (_showAddLeadForm) {
      return AddLeadsScreen(
        onBack: () => setState(() => _showAddLeadForm = false),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: widget.onBack,
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (!_selectionMode)
            IconButton(
              icon: Icon(LucideIcons.trash2, color: Colors.red.shade400),
              tooltip: 'Delete leads',
              onPressed: () => setState(() => _selectionMode = true),
            ),
          if (_selectionMode)
            IconButton(
              icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
              tooltip: 'Cancel selection',
              onPressed: () => setState(() {
                _selectionMode = false;
                _selectedLeadIds.clear();
              }),
            ),
          if (!_selectionMode && widget.leadType == 'hot')
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => setState(() => _showAddLeadForm = true),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ),
        ]),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: LeadService.leadsStream(type: widget.leadType),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var docs = snapshot.data?.docs.toList() ?? [];
                if (_query.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data();
                    final name =
                        (data['name'] as String? ?? '').toLowerCase();
                    final phone =
                        (data['phone'] as String? ?? '').toLowerCase();
                    final notes =
                        (data['notes'] as String? ?? '').toLowerCase();
                    return name.contains(_query) ||
                        phone.contains(_query) ||
                        notes.contains(_query);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_fire_department_outlined,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No ${widget.title} Yet',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(widget.leadType == 'hot'
                            ? 'Tap + to add your first lead.'
                            : 'Tag a call log to add it here.',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                }

                final allSelected = docs.isNotEmpty &&
                    docs.every((doc) => _selectedLeadIds.contains(doc.id));
                return Column(
                  children: [
                    if (_selectionMode)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Row(children: [
                          Checkbox(
                            value: allSelected,
                            onChanged: (selected) => setState(() {
                              if (selected == true) {
                                _selectedLeadIds.addAll(docs.map((doc) => doc.id));
                              } else {
                                _selectedLeadIds.removeAll(docs.map((doc) => doc.id));
                              }
                            }),
                          ),
                          Text(allSelected ? 'Deselect All' : 'Select All'),
                          const Spacer(),
                          if (_selectedLeadIds.isNotEmpty)
                            IconButton(
                              icon: Icon(LucideIcons.trash2, color: Colors.red),
                              onPressed: _deleteSelectedLeads,
                            ),
                        ]),
                      ),
                    Expanded(child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return _buildLeadCard(context, doc.id, doc.data());
                  },
                    )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard(
      BuildContext context, String id, Map<String, dynamic> data) {
    final name = data['name'] as String? ?? 'Unknown';
    final phone = data['phone'] as String? ?? '';
    final notes = data['notes'] as String? ?? '';
    final dateTime = data['dateTime'] as String? ?? data['date'] as String? ?? '';
    final duration = data['duration'] as String? ?? '';
    final callType = data['callType'] as String? ?? 'outgoing';

    final isSelected = _selectedLeadIds.contains(id);
    return GestureDetector(
      onTap: () {
        if (_selectionMode) {
          setState(() => isSelected
              ? _selectedLeadIds.remove(id)
              : _selectedLeadIds.add(id));
          return;
        }
        setState(() {
          _selectedLead = CallLogItem(
            id: id,
            name: name,
            phoneNumber: phone,
            dateTime: dateTime,
            duration: duration,
            callType: callType,
            activeTag: 'Hot leads',
            isConverted: data['converted'] as bool? ?? false,
            notes: notes,
            isLead: true,
          );
        });
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.08)
            : Theme.of(context).cardColor,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectionMode) ...[
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => setState(() => isSelected
                      ? _selectedLeadIds.remove(id)
                      : _selectedLeadIds.add(id)),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Jul 9, 2:40 PM • 1m 20s', // Placeholder for actual time if available
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_vert, color: Colors.grey.shade400),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  label: 'Call',
                  icon: Icons.call_outlined,
                  color: AppColors.primary,
                  bg: AppColors.callOutgoingBg, // Using standard call outgoing bg
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  label: 'WhatsApp',
                  icon: Icons.chat_bubble_outline,
                  color: const Color(0xFF25D366),
                  bg: const Color(0xFFE8F8F0),
                ),
              ),
            ],
          ),
        ],
      ),
      ), // Container
    ); // GestureDetector
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
