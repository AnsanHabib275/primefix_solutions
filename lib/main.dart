import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/utils/error_handler.dart';
import 'controllers/auth_controller.dart';
import 'controllers/location_controller.dart';
import 'controllers/notification_controller.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // System UI Configuration
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    // Initialize core services
    await _initializeServices();

    // Setup dependencies
    _setupDependencies();

    runApp(const MyApp());
  } catch (error, stackTrace) {
    debugPrint(error.toString());
    // ErrorHandler.handleError(error, stackTrace);
  }
}

Future<void> _initializeServices() async {
  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize local storage
  await GetStorage.init();
  await Hive.initFlutter();

  // Initialize services
  // await StorageService.initialize();
  // await ApiService.initialize();
  // await NotificationService.initialize();
  // await FirebaseService.initialize();

  debugPrint('✅ All services initialized successfully');
}

void _setupDependencies() {
  // Get.put(AuthController(), permanent: true);
  // Get.put(LocationController(), permanent: true);
  // Get.put(NotificationController(), permanent: true);

  debugPrint('✅ Dependencies initialized');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,

          // Localization
          locale: const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),

          // Navigation
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.routes,

          // Error handling
          // errorBuilder:
          //     (context, error) =>
          //         AppErrorBoundary(error: error, child: Container()),

          // Global app bar theme
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(1.0), // Prevent text scaling
              ),
              child: widget ?? Container(),
            );
          },
        );
      },
    );
  }
}

class AppErrorBoundary extends StatelessWidget {
  final String? error;
  final Widget child;

  const AppErrorBoundary({super.key, this.error, required this.child});

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Get.offAllNamed(AppRoutes.splash);
                },
                child: const Text('Restart App'),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}
