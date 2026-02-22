import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../shared/enums/user_role.dart';

// Screen imports
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/home/rider_home_screen.dart';
import '../../presentation/screens/home/driver_home_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/contacts/contacts_screen.dart';
import '../../presentation/screens/contacts/add_contact_screen.dart';
import '../../presentation/screens/places/saved_places_screen.dart';
import '../../presentation/screens/booking/booking_screen.dart';
import '../../presentation/screens/booking/booking_search_screen.dart';
import '../../presentation/screens/booking/booking_confirmation_screen.dart';
import '../../presentation/screens/booking/trip_screen.dart';
import '../../presentation/screens/promo/promo_screen.dart';
import '../../presentation/screens/promo/referral_screen.dart';
import '../../presentation/screens/driver/driver_application_screen.dart';
import '../../presentation/screens/driver/driver_dashboard_screen.dart';
import '../../presentation/screens/driver/driver_earnings_screen.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/driver_approvals_screen.dart';
import '../../presentation/screens/admin/active_trips_screen.dart';
import '../../presentation/screens/admin/assign_driver_screen.dart';
import '../../presentation/screens/history/ride_history_screen.dart';

/// GoRouter configuration with role-based guards
class AppRouter {
  static GoRouter router(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuth = authProvider.isAuthenticated;
        final isAuthRoute =
            state.matchedLocation.startsWith('/auth') ||
            state.matchedLocation == '/splash' ||
            state.matchedLocation == '/onboarding';

        // Not authenticated -> redirect to login
        if (!isAuth && !isAuthRoute) return '/auth/login';

        // Authenticated on auth route -> redirect to home
        if (isAuth && isAuthRoute && state.matchedLocation != '/splash') {
          return _homeRoute(authProvider.activeRole);
        }

        return null;
      },
      routes: [
        // ─── Splash ───
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // ─── Onboarding ───
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),

        // ─── Auth Routes ───
        GoRoute(
          path: '/auth/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/auth/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/auth/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // ─── Rider Home ───
        GoRoute(
          path: '/rider',
          builder: (context, state) => const RiderHomeScreen(),
        ),

        // ─── Driver Home ───
        GoRoute(
          path: '/driver',
          builder: (context, state) => const DriverHomeScreen(),
        ),

        // ─── Profile ───
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (context, state) => const EditProfileScreen(),
        ),

        // ─── Booking ───
        GoRoute(
          path: '/booking',
          builder: (context, state) => const BookingScreen(),
        ),
        GoRoute(
          path: '/booking/search',
          builder: (context, state) => const BookingSearchScreen(),
        ),
        GoRoute(
          path: '/booking/confirmation',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return BookingConfirmationScreen(
              pickupAddress:
                  extra['pickupAddress'] as String? ?? 'Current Location',
              dropoffAddress:
                  extra['dropoffAddress'] as String? ?? 'Destination',
            );
          },
        ),
        GoRoute(
          path: '/booking/trip',
          builder: (context, state) => const TripScreen(),
        ),

        // ─── Contacts ───
        GoRoute(
          path: '/contacts',
          builder: (context, state) => const ContactsScreen(),
        ),
        GoRoute(
          path: '/contacts/add',
          builder: (context, state) => const AddContactScreen(),
        ),

        // ─── Saved Places ───
        GoRoute(
          path: '/places',
          builder: (context, state) => const SavedPlacesScreen(),
        ),

        // ─── Promos & Referrals ───
        GoRoute(
          path: '/promos',
          builder: (context, state) => const PromoScreen(),
        ),
        GoRoute(
          path: '/referrals',
          builder: (context, state) => const ReferralScreen(),
        ),

        // ─── Driver-specific ───
        GoRoute(
          path: '/driver/apply',
          builder: (context, state) => const DriverApplicationScreen(),
        ),
        GoRoute(
          path: '/driver/dashboard',
          builder: (context, state) => const DriverDashboardScreen(),
        ),
        GoRoute(
          path: '/driver/earnings',
          builder: (context, state) => const DriverEarningsScreen(),
        ),

        // ─── Settings ───
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const RideHistoryScreen(),
        ),

        // ─── Admin ───
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/admin/driver-approvals',
          builder: (context, state) => const DriverApprovalsScreen(),
        ),
        GoRoute(
          path: '/admin/active-trips',
          builder: (context, state) => const ActiveTripsScreen(),
        ),
        GoRoute(
          path: '/admin/assign-driver/:bookingId',
          builder: (context, state) =>
              AssignDriverScreen(bookingId: state.pathParameters['bookingId']!),
        ),
      ],
    );
  }

  static String _homeRoute(UserRole role) {
    switch (role) {
      case UserRole.driver:
        return '/driver';
      case UserRole.admin:
      case UserRole.superAdmin:
        return '/admin';
      default:
        return '/rider';
    }
  }
}
