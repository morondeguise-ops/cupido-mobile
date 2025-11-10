import 'package:flutter/material.dart';

import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/phone_auth_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/auth/screens/registration_screen.dart';
import '../../features/onboarding/screens/profile_setup_screen.dart';
import '../../features/onboarding/screens/photo_upload_screen.dart';
import '../../features/onboarding/screens/hobby_selection_screen.dart';
import '../../features/home/screens/main_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/discover/screens/discover_screen.dart';
import '../../features/matches/screens/matches_screen.dart';
import '../../features/messages/screens/chat_screen.dart';
import '../../features/feed/screens/feed_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

class AppRouter {
  // Route names
  static const String welcome = '/';
  static const String phoneAuth = '/phone-auth';
  static const String otpVerification = '/otp-verification';
  static const String registration = '/registration';
  static const String profileSetup = '/profile-setup';
  static const String photoUpload = '/photo-upload';
  static const String hobbySelection = '/hobby-selection';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String discover = '/discover';
  static const String matches = '/matches';
  static const String chat = '/chat';
  static const String feed = '/feed';
  static const String settings = '/settings';

  // Generate routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case phoneAuth:
        return MaterialPageRoute(builder: (_) => const PhoneAuthScreen());

      case otpVerification:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phone: args['phone'],
            purpose: args['purpose'],
          ),
        );

      case registration:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => RegistrationScreen(phone: args['phone']),
        );

      case profileSetup:
        return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());

      case photoUpload:
        return MaterialPageRoute(builder: (_) => const PhotoUploadScreen());

      case hobbySelection:
        return MaterialPageRoute(builder: (_) => const HobbySelectionScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case profile:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(userId: args?['userId']),
        );

      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case discover:
        return MaterialPageRoute(builder: (_) => const DiscoverScreen());

      case matches:
        return MaterialPageRoute(builder: (_) => const MatchesScreen());

      case chat:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            matchId: args['matchId'],
            matchedUser: args['matchedUser'],
          ),
        );

      case feed:
        return MaterialPageRoute(builder: (_) => const FeedScreen());

      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
