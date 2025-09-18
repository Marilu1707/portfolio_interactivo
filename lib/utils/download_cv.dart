import 'package:flutter/widgets.dart';

import 'download_cv_stub.dart'
    if (dart.library.html) 'download_cv_web.dart'
    if (dart.library.io) 'download_cv_io.dart' as impl;

Future<void> descargarCV(BuildContext context) => impl.descargarCV(context);

