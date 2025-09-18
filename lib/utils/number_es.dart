import 'package:intl/intl.dart';

// Utilidades de formateo numérico para es-AR
final nfInt = NumberFormat.decimalPattern('es_AR');
String fmtInt(int n) => nfInt.format(n);

String fmt1(double x) => NumberFormat('0.0', 'es_AR').format(x);

String fmtPct1(double x) =>
    NumberFormat.decimalPercentPattern(locale: 'es_AR', decimalDigits: 1)
        .format(x);
