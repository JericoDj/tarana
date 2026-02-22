import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/gradient_button.dart';

class BookingSearchScreen extends StatefulWidget {
  const BookingSearchScreen({super.key});

  @override
  State<BookingSearchScreen> createState() => _BookingSearchScreenState();
}

class _BookingSearchScreenState extends State<BookingSearchScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default pickup to current location
    _pickupController.text = 'Current Location';
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  void _onSearch() {
    if (_dropoffController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a destination')),
      );
      return;
    }

    // For MVP, we will pass the text to the confirmation screen.
    // In a real app, we would use Google Places API here to get the LatLng.
    // For now, let's navigate to confirmation with dummy coordinates based on the text.
    context.push(
      '/booking/confirmation',
      extra: {
        'pickupAddress': _pickupController.text,
        'dropoffAddress': _dropoffController.text,
      },
    );
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
        title: const Text('Search Destination'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _pickupController,
              labelText: 'Pickup Location',
              prefixIcon: Icons.my_location_rounded,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _dropoffController,
              labelText: 'Where to?',
              hintText: 'Enter destination address',
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 24),
            GradientButton(text: 'Find Ride', onPressed: _onSearch),
            const SizedBox(height: 24),
            Text('Recent Destinations', style: AppTextStyles.h4),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: 3,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final places = [
                    'SM Mall of Asia',
                    'Makati Medical Center',
                    'BGC High Street',
                  ];
                  final addresses = [
                    'Pasay City, Metro Manila',
                    'Amorsolo St, Makati City',
                    '5th Ave, Taguig',
                  ];

                  return ListTile(
                    leading: const Icon(
                      Icons.history_rounded,
                      color: AppColors.textTertiary,
                    ),
                    title: Text(places[index], style: AppTextStyles.bodyMedium),
                    subtitle: Text(
                      addresses[index],
                      style: AppTextStyles.caption,
                    ),
                    onTap: () {
                      _dropoffController.text = places[index];
                      _onSearch();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
