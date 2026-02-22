import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contact_provider.dart';
import '../../../data/models/contact_model.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<ContactProvider>().watchContacts(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop(),
          ),
          title: const Text('Contacts'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Emergency'),
              Tab(text: 'Passengers'),
            ],
          ),
        ),
        body: Consumer<ContactProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.contacts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null && provider.contacts.isEmpty) {
              return Center(child: Text(provider.error!));
            }

            return TabBarView(
              children: [
                _buildContactList(
                  provider.emergencyContacts,
                  isEmergency: true,
                ),
                _buildContactList(provider.savedPassengers, isEmergency: false),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/contacts/add'),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildContactList(
    List<ContactModel> contacts, {
    required bool isEmergency,
  }) {
    if (contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEmergency ? Icons.warning_amber_rounded : Icons.people_outline,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              isEmergency ? 'No emergency contacts' : 'No saved passengers',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 8),
            Text('Tap + to add a new contact.', style: AppTextStyles.bodySmall),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Card(
          elevation: 0,
          color: AppColors.surface,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: isEmergency
                  ? Colors.red.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              child: Icon(
                isEmergency ? Icons.warning_rounded : Icons.person_rounded,
                color: isEmergency ? Colors.red : AppColors.primary,
              ),
            ),
            title: Text(contact.name, style: AppTextStyles.bodyLarge),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(contact.phone, style: AppTextStyles.bodySmall),
                if (contact.relationship != null &&
                    contact.relationship!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      contact.relationship!,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _confirmDelete(context, contact),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext ctx, ContactModel contact) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(dialogCtx);
              final uid = ctx.read<AuthProvider>().user?.uid;
              if (uid != null) {
                ctx.read<ContactProvider>().deleteContact(uid, contact.id);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
