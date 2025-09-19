import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:overlay_support/overlay_support.dart';

// Screens
import 'home_screen.dart';
import 'screens/level1_game_screen.dart';
import 'screens/level2_eda_screen.dart';
import 'screens/level3_inventory_screen.dart';
import 'screens/level4_mlprediction_screen.dart';
import 'screens/level5_abtest_screen.dart';
import 'screens/dashboard_screen.dart';

// Theme & state
import 'theme/kawaii_theme.dart';
import 'services/data_service.dart';
import 'state/app_state.dart';
import 'state/orders_state.dart';
import 'state/ab_result_state.dart';

// Punto de entrada: configura locale es-AR, carga inventario y provee AppState
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Use hash URLs to avoid 404s on static hosts without rewrites
  if (kIsWeb) {
    setUrlStrategy(const HashUrlStrategy());
  }

  // Log uncaught Flutter errors in production to the browser console
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // ignore: avoid_print
    print('FlutterError: ${details.exceptionAsString()}');
  };
  Intl.defaultLocale = 'es_AR';
  final seed = await DataService.loadInventory();

  final appState = AppState()..initInventory(seed);
  final ordersState = OrdersState();
  await ordersState.load();

  runApp(
    OverlaySupport.global(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: appState),
          ChangeNotifierProvider.value(value: ordersState),
          ChangeNotifierProvider(create: (_) => ABResultState()..load()),
        ],
        child: const MariluApp(),
      ),
    ),
  );
}

// MaterialApp con rutas a 5 pantallas y tema kawaii
  class MariluApp extends StatelessWidget {
    const MariluApp({super.key});

    @override
    Widget build(BuildContext context) {
      // Friendly error widget in case a subtree fails to build
      ErrorWidget.builder = (details) => Material(
            color: const Color(0xFFFFF9E8),
            child: Center(
              child: Text(
                'Ups… ${details.exception}',
                style: const TextStyle(color: Colors.brown),
                textAlign: TextAlign.center,
              ),
            ),
          );
      return MaterialApp(
        locale: const Locale('es', 'AR'),
      supportedLocales: const [Locale('es', 'AR'), Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Limita el escalado de texto para evitar truncados en web/desktop
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
              textScaler: media.textScaler
                  .clamp(minScaleFactor: 0.9, maxScaleFactor: 1.15)),
          child: child!,
        );
      },
      title: 'Marilú - Ciencia de Datos',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _NoGlowScrollBehavior(),
      theme: KawaiiTheme.materialTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeDesktop(),
        '/level1': (_) => const Level1GameScreen(),
        '/level2': (_) => const Level2EdaScreen(),
        '/level3': (_) => const Level3InventoryScreen(),
        '/level4': (_) => const Level4MlPredictionScreen(),
        '/level5': (_) => const Level5AbTestScreen(),
        '/dashboard': (_) => const Level5DashboardScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const HomeDesktop(),
      ),
    );
  }
}

// Remove scroll glow on web/desktop
class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;
}
