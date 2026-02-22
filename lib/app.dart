import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/driver_application_provider.dart';
import 'presentation/providers/location_provider.dart';
import 'presentation/providers/map_provider.dart';
import 'presentation/providers/place_provider.dart';
import 'presentation/providers/booking_provider.dart';
import 'presentation/providers/contact_provider.dart';
import 'presentation/providers/promo_provider.dart';
import 'data/repositories/contact_repository.dart';
import 'data/repositories/promo_repository.dart';
import 'data/repositories/referral_repository.dart';
import 'data/datasources/remote/firestore_source.dart';
import 'data/datasources/remote/cloud_functions_source.dart';

/// Root widget for the Tarana app
class TaranaApp extends StatelessWidget {
  const TaranaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (context) => DriverApplicationProvider(
            authProvider: context.read<AuthProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              LocationProvider(authProvider: context.read<AuthProvider>()),
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(
          create: (context) =>
              PlaceProvider(authProvider: context.read<AuthProvider>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              BookingProvider(authProvider: context.read<AuthProvider>()),
        ),
        ChangeNotifierProvider(
          create: (context) {
            // Instantiate FirestoreSource directly, as it doesn't need AuthProvider state
            final firestoreSource = FirestoreSource();
            return ContactProvider(ContactRepository(firestoreSource));
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final firestoreSource = FirestoreSource();
            final cloudFunctions = CloudFunctionsSource();
            return PromoProvider(
              PromoRepository(firestoreSource),
              ReferralRepository(firestoreSource),
              cloudFunctions,
            );
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.router(context);

          return MaterialApp.router(
            title: 'Tarana',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
