import 'package:get/get.dart';
import '../ui/screens/splash/splash_screen.dart';
import '../ui/screens/auth/welcome_screen.dart';
import '../ui/screens/auth/phone_auth_screen.dart';
import '../ui/screens/user/home_screen.dart';
import '../ui/screens/worker/dashboard_screen.dart';

class AppRoutes {
  // Route Names
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String phoneAuth = '/phone-auth';
  static const String otpVerification = '/otp-verification';
  static const String roleSelection = '/role-selection';
  static const String userHome = '/user-home';
  static const String workerDashboard = '/worker-dashboard';

  // Route List
  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: welcome, page: () => const WelcomeScreen()),
    GetPage(name: phoneAuth, page: () => const PhoneAuthScreen()),
    GetPage(name: userHome, page: () => const UserHomeScreen()),
    GetPage(name: workerDashboard, page: () => const WorkerDashboardScreen()),
  ];
}
