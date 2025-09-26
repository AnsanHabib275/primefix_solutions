import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/auth_gate.dart';
import '../features/home/presentation/customer_home_page.dart';
import '../features/home/presentation/worker_home_page.dart';
import '../features/admin/presentation/admin_home_page.dart';
import '../features/payments/presentation/payment_demo_page.dart';
import '../features/maps/presentation/tracking_map_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth',
    refreshListenable: GoRouterAuthNotifier(ref),
    routes: [
      GoRoute(path: '/auth', builder: (_, __) => const AuthGate()),
      GoRoute(path: '/customer', builder: (_, __) => const CustomerHomePage()),
      GoRoute(path: '/worker', builder: (_, __) => const WorkerHomePage()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminHomePage()),
      GoRoute(path: '/payment', builder: (_, __) => const PaymentDemoPage()),
      GoRoute(path: '/tracking', builder: (_, __) => const TrackingMapPage()),
    ],
    redirect: (context, state) {
      final auth = ref.read(authStateProvider).valueOrNull;
      final isLoggedIn = auth != null;
      final role = ref.read(appUserProvider).valueOrNull?.role;

      if (!isLoggedIn && state.uri.toString() != '/auth') return '/auth';
      if (isLoggedIn && state.uri.toString() == '/auth') {
        if (role == 'worker') return '/worker';
        if (role == 'admin') return '/admin';
        return '/customer';
      }
      return null;
    },
  );
});

class GoRouterAuthNotifier extends ChangeNotifier {
  GoRouterAuthNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(appUserProvider, (_, __) => notifyListeners());
  }
}
