import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'firebase_options.dart';
import 'src/app/router.dart';
import 'src/app/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'src/features/auth/data/auth_repository.dart';
import 'src/features/notifications/fcm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    ref.listen(authStateProvider, (_, next) {
      final u = next.valueOrNull;
      if (u != null) initFcmToken(u.uid);
    });
    return MaterialApp.router(
      title: 'PrimeFix Solutions',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      supportedLocales: const [Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
