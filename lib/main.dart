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

void main() {
  // Asegura que el motor de Flutter esté listo antes de usar canales nativos.
  WidgetsFlutterBinding.ensureInitialized();
  // Redirigimos los errores globales para imprimirlos en consola con stacktrace.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER ERROR: ${details.exceptionAsString()}');
    if (details.stack != null) {
      debugPrint(details.stack.toString());
    }
  };
  if (kIsWeb) {
    // Usa rutas limpias sin hash cuando se ejecuta en navegador.
    setUrlStrategy(PathUrlStrategy());
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<_AppDependencies> _initFuture;

  @override
  void initState() {
    super.initState();
    // Pre-cargamos los servicios y estado global antes de construir la UI.
    _initFuture = _loadDependencies();
  }

  Future<_AppDependencies> _loadDependencies() async {
    // Configura el locale por defecto para formatos y fechas.
    Intl.defaultLocale = 'es_AR';
    final seed = await DataService.loadInventory();

    // Estados compartidos que se inyectarán con Provider.
    final appState = AppState()..initInventory(seed);
    final ordersState = OrdersState();
    await ordersState.load();
    final abState = ABResultState();
    await abState.load();

    return _AppDependencies(
      appState: appState,
      ordersState: ordersState,
      abState: abState,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppDependencies>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // Splash mínimo mientras se inicializa la aplicación.
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Color(0xFFFFF9E8),
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          // Mensaje de error amigable si falló la carga inicial.
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: const Color(0xFFFFF6E5),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Ups... ocurrió un error al iniciar.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.brown, fontSize: 16),
                  ),
                ),
              ),
            ),
          );
        }

        final deps = snapshot.data!;
        // Inyectamos los estados compartidos en el árbol de widgets.
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: deps.appState),
            ChangeNotifierProvider.value(value: deps.ordersState),
            ChangeNotifierProvider.value(value: deps.abState),
          ],
          child: const MariluApp(),
        );
      },
    );
  }
}

class _AppDependencies {
  final AppState appState;
  final OrdersState ordersState;
  final ABResultState abState;

  const _AppDependencies({
    required this.appState,
    required this.ordersState,
    required this.abState,
  });
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
        // Limita la escala de texto del sistema para preservar el diseño.
        return MediaQuery(
          data: media.copyWith(
            textScaler:
                media.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.15),
          ),
          child: child!,
        );
      },
      title: 'Marilu - Ciencia de Datos',
      // Evita el efecto glow de scroll en web/desktop.
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
    // Devuelve el child directamente para eliminar la animación por defecto.
    return child;
  }
}
