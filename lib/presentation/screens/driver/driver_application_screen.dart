import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../providers/driver_application_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/profile/photo_upload_widget.dart';

class DriverApplicationScreen extends StatefulWidget {
  const DriverApplicationScreen({super.key});

  @override
  State<DriverApplicationScreen> createState() =>
      _DriverApplicationScreenState();
}

class _DriverApplicationScreenState extends State<DriverApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Vehicle Info
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();

  // Documents
  File? _licenseImage;
  File? _registrationImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverApplicationProvider>().fetchApplication();
    });
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_licenseImage == null) {
      _showError('Please upload your Driver\'s License');
      return;
    }

    if (_registrationImage == null) {
      _showError('Please upload your Vehicle Registration');
      return;
    }

    final vehicleInfo = {
      'make': _makeController.text.trim(),
      'model': _modelController.text.trim(),
      'year': _yearController.text.trim(),
      'plateNumber': _plateController.text.trim(),
    };

    final provider = context.read<DriverApplicationProvider>();
    final success = await provider.submitApplication(
      vehicleInfo: vehicleInfo,
      licenseFile: _licenseImage!,
      registrationFile: _registrationImage!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else if (provider.error != null && mounted) {
      _showError(provider.error!);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverApplicationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Become a Driver'),
      ),
      body: provider.isLoading && provider.application == null
          ? const Center(child: CircularProgressIndicator())
          : provider.application != null
          ? _AlreadyAppliedView(status: provider.application!.status.name)
          : _ApplicationForm(
              formKey: _formKey,
              makeController: _makeController,
              modelController: _modelController,
              yearController: _yearController,
              plateController: _plateController,
              licenseImage: _licenseImage,
              registrationImage: _registrationImage,
              onLicenseSelected: (file) => setState(() => _licenseImage = file),
              onRegistrationSelected: (file) =>
                  setState(() => _registrationImage = file),
              onSubmit: _submit,
              isLoading: provider.isLoading,
            ),
    );
  }
}

class _ApplicationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController makeController;
  final TextEditingController modelController;
  final TextEditingController yearController;
  final TextEditingController plateController;
  final File? licenseImage;
  final File? registrationImage;
  final Function(File) onLicenseSelected;
  final Function(File) onRegistrationSelected;
  final VoidCallback onSubmit;
  final bool isLoading;

  const _ApplicationForm({
    required this.formKey,
    required this.makeController,
    required this.modelController,
    required this.yearController,
    required this.plateController,
    required this.licenseImage,
    required this.registrationImage,
    required this.onLicenseSelected,
    required this.onRegistrationSelected,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle Information', style: AppTextStyles.h4),
            const SizedBox(height: 16),
            CustomTextField(
              controller: makeController,
              labelText: 'Make (e.g. Toyota)',
              validator: (v) => Validators.required(v, 'Make'),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: modelController,
              labelText: 'Model (e.g. Vios)',
              validator: (v) => Validators.required(v, 'Model'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: yearController,
                    labelText: 'Year',
                    keyboardType: TextInputType.number,
                    validator: (v) => Validators.required(v, 'Year'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: plateController,
                    labelText: 'Plate No.',
                    validator: Validators.plateNumber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Required Documents', style: AppTextStyles.h4),
            const SizedBox(height: 8),
            Text(
              'Please upload clear photos of your documents',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            _DocumentUploadRow(
              title: "Driver's License",
              imageFile: licenseImage,
              onSelected: onLicenseSelected,
            ),
            const SizedBox(height: 12),
            _DocumentUploadRow(
              title: "Vehicle Registration",
              imageFile: registrationImage,
              onSelected: onRegistrationSelected,
            ),

            const SizedBox(height: 32),
            GradientButton(
              text: 'Submit Application',
              isLoading: isLoading,
              onPressed: onSubmit,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _DocumentUploadRow extends StatelessWidget {
  final String title;
  final File? imageFile;
  final Function(File) onSelected;

  const _DocumentUploadRow({
    required this.title,
    required this.imageFile,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  imageFile != null ? 'Uploaded' : 'Required',
                  style: AppTextStyles.caption.copyWith(
                    color: imageFile != null
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            height: 60,
            child: PhotoUploadWidget(onPhotoSelected: onSelected),
          ),
        ],
      ),
    );
  }
}

class _AlreadyAppliedView extends StatelessWidget {
  final String status;
  const _AlreadyAppliedView({required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.outbox_rounded, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'Application Submitted',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your application is currently $status. We will notify you once an admin has reviewed your documents.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GradientButton(text: 'Go Back', onPressed: () => context.pop()),
        ],
      ),
    );
  }
}
