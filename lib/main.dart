import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/config/app_config.dart';
import 'core/services/notification_service.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
    // Continue without Firebase - app can still run
  }

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize notifications (skip on web as it requires Firebase)
  try {
    if (!kIsWeb) {
      await NotificationService.initialize();
    }
  } catch (e) {
    debugPrint('Notification service initialization failed: $e');
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: CupidoApp(),
    ),
  );
}

class CupidoApp extends ConsumerWidget {
  const CupidoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Cupido',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: authState.isAuthenticated
          ? AppRouter.home
          : AppRouter.welcome,
    );
  }
}
