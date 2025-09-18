import 'email_launcher_stub.dart'
    if (dart.library.html) 'email_launcher_web.dart'
    if (dart.library.io) 'email_launcher_stub.dart' as impl;

Future<void> composeEmail({
  required String to,
  String subject = '',
  String body = '',
  List<String> cc = const [],
  List<String> bcc = const [],
}) => impl.composeEmail(to: to, subject: subject, body: body, cc: cc, bcc: bcc);

