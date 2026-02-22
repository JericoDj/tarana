import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';

import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/profile/photo_upload_widget.dart';
import '../../../services/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  File? _selectedPhoto;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    String? photoUrl = auth.user?.photoUrl;

    if (_selectedPhoto != null && auth.user != null) {
      setState(() => _isUploadingPhoto = true);
      try {
        final storageService = StorageService();
        photoUrl = await storageService.uploadProfilePhoto(
          uid: auth.user!.uid,
          file: _selectedPhoto!,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to upload photo: $e')));
        }
        setState(() => _isUploadingPhoto = false);
        return; // Stop if photo upload fails
      }
      setState(() => _isUploadingPhoto = false);
    }

    final success = await auth.updateProfile(
      displayName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      photoUrl: photoUrl,
    );
    if (success && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final isSaving = context.watch<AuthProvider>().isLoading;
    final isLoading = isSaving || _isUploadingPhoto;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              PhotoUploadWidget(
                initialUrl: user?.photoUrl,
                isLoading: _isUploadingPhoto,
                onPhotoSelected: (file) {
                  setState(() {
                    _selectedPhoto = file;
                  });
                },
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _nameController,
                labelText: 'Full Name',
                prefixIcon: Icons.person_outline,
                validator: (v) => Validators.required(v, 'Name'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),
              const SizedBox(height: 32),
              GradientButton(
                text: 'Save Changes',
                isLoading: isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
