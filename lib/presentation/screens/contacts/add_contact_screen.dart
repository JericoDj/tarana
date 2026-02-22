import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/contact_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contact_provider.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationshipController = TextEditingController();
  String _contactType = 'emergency';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Add Contact'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Contact type selector
              Text('Contact Type', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'emergency',
                    label: Text('Emergency'),
                    icon: Icon(Icons.warning_amber_rounded),
                  ),
                  ButtonSegment(
                    value: 'passenger',
                    label: Text('Passenger'),
                    icon: Icon(Icons.person_rounded),
                  ),
                ],
                selected: {_contactType},
                onSelectionChanged: (value) {
                  setState(() => _contactType = value.first);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary.withOpacity(0.1);
                    }
                    return null;
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Relationship field (optional)
              TextFormField(
                controller: _relationshipController,
                decoration: InputDecoration(
                  labelText: 'Relationship (optional)',
                  hintText: _contactType == 'emergency'
                      ? 'e.g. Spouse, Parent, Friend'
                      : 'e.g. Colleague, Family Member',
                  prefixIcon: const Icon(Icons.group_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 32),

              // Save button
              Consumer<ContactProvider>(
                builder: (context, provider, child) {
                  return FilledButton.icon(
                    onPressed: provider.isLoading ? null : _saveContact,
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(
                      provider.isLoading ? 'Saving...' : 'Save Contact',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;

    final contact = ContactModel(
      id: '', // Will be assigned by Firestore
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      type: _contactType,
      relationship: _relationshipController.text.trim().isNotEmpty
          ? _relationshipController.text.trim()
          : null,
      createdAt: DateTime.now(),
    );

    await context.read<ContactProvider>().addContact(uid, contact);

    if (mounted) {
      final error = context.read<ContactProvider>().error;
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact saved successfully!')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }
}
