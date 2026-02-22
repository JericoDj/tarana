import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';

class PhotoUploadWidget extends StatefulWidget {
  final String? initialUrl;
  final Function(File) onPhotoSelected;
  final bool isLoading;

  const PhotoUploadWidget({
    super.key,
    this.initialUrl,
    required this.onPhotoSelected,
    this.isLoading = false,
  });

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() {
          _selectedImage = file;
        });
        widget.onPhotoSelected(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: widget.isLoading ? null : _showPickerOptions,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.cardBackground,
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : (widget.initialUrl != null
                            ? NetworkImage(widget.initialUrl!)
                            : null)
                        as ImageProvider?,
              child: _selectedImage == null && widget.initialUrl == null
                  ? const Icon(
                      Icons.person_outline,
                      size: 60,
                      color: AppColors.textTertiary,
                    )
                  : null,
            ),
            if (widget.isLoading)
              const Positioned.fill(
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!widget.isLoading)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
