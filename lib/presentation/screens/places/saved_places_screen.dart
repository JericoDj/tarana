import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/place_provider.dart';
import '../../widgets/common/custom_text_field.dart';

class SavedPlacesScreen extends StatelessWidget {
  const SavedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Saved Places'),
      ),
      body: Consumer<PlaceProvider>(
        builder: (context, placeProvider, child) {
          if (placeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (placeProvider.error != null) {
            return Center(
              child: Text(
                placeProvider.error!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            );
          }

          final places = placeProvider.savedPlaces;

          if (places.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text('No saved places', style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  Text(
                    'Save your favorite locations for quick booking',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: places.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final place = places[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withAlpha(
                      (0.2 * 255).round(),
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    place.label.toLowerCase() == 'home'
                        ? Icons.home
                        : place.label.toLowerCase() == 'work'
                        ? Icons.work
                        : Icons.location_on,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(place.label, style: AppTextStyles.h4),
                subtitle: Text(
                  place.address,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  onPressed: () async {
                    // Show confirmation dialog before deleting
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Place'),
                        content: Text(
                          'Are you sure you want to delete ${place.label}?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => context.pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => context.pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await placeProvider.deleteSavedPlace(place.id);
                    }
                  },
                ),
                onTap: () {
                  // Handle tap: e.g. return this place to booking screen
                  context.pop(place);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlaceDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddPlaceDialog(BuildContext context) async {
    final labelCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final placeProvider = context.read<PlaceProvider>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add Saved Place', style: AppTextStyles.h4),
              const SizedBox(height: 24),
              CustomTextField(
                controller: labelCtrl,
                labelText: 'Label (e.g., Gym, School)',
                hintText: 'Enter a label',
                prefixIcon: Icons.label_outline,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: addressCtrl,
                labelText: 'Address',
                hintText: 'Enter full address',
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (labelCtrl.text.isEmpty || addressCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  // TODO: Geocode address to lat/lng using geocoding package
                  // For now, using mock coordinates
                  await placeProvider.addSavedPlace(
                    label: labelCtrl.text,
                    address: addressCtrl.text,
                    lat: 14.5995, // Manila mock
                    lng: 120.9842,
                  );

                  if (context.mounted) {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${labelCtrl.text} added!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Place',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
