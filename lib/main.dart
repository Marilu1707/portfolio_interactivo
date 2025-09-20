import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/level1_game_screen.dart';
import 'screens/level2_eda_screen.dart';
import 'screens/level3_inventory_screen.dart';
import 'screens/level4_mlprediction_screen.dart';
import 'screens/level5_abtest_screen.dart';
import 'services/data_service.dart';
import 'state/ab_result_state.dart';
import 'state/app_state.dart';
import 'state/orders_state.dart';
import 'theme/kawaii_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER ERROR: ${details.exceptionAsString()}');
    if (details.stack != null) {
      debugPrint(details.stack.toString());
    }
  };

  runApp(const _BootstrapApp());

  if (kIsWeb) {
    setUrlStrategy(const HashUrlStrategy());
  }

  try {
    Intl.defaultLocale = 'es_AR';
    final seed = await DataService.loadInventory();

    final appState = AppState()..initInventory(seed);
    final ordersState = OrdersState();
    await ordersState.load();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: appState),
          ChangeNotifierProvider.value(value: ordersState),
          ChangeNotifierProvider(create: (_) => ABResultState()..load()),
        ],
        child: const MariluApp(),
      ),
    );
  } catch (error, stack) {
    debugPrint('UNCAUGHT INIT ERROR: $error');
    debugPrint(stack.toString());
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFFFFF6E5),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Ups... ocurrió un error al iniciar.\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.brown, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BootstrapApp extends StatelessWidget {
  const _BootstrapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text('Cargando app...')),
      ),
    );
  }
}

class MariluApp extends StatelessWidget {
  const MariluApp({super.key});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (details) => Material(
          color: const Color(0xFFFFF9E8),
          child: Center(
            child: Text(
              'Ups... ${details.exception}',
              style: const TextStyle(color: Colors.brown),
              textAlign: TextAlign.center,
            ),
          ),
        );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'AR'),
      supportedLocales: const [
        Locale('es', 'AR'),
        Locale('es'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler:
                media.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.15),
          ),
          child: child!,
        );
      },
      title: 'Marilu - Ciencia de Datos',
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

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
