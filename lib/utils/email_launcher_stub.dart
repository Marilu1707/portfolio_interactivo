import 'package:url_launcher/url_launcher.dart';

Future<void> composeEmail({
  required String to,
  String subject = '',
  String body = '',
  List<String> cc = const [],
  List<String> bcc = const [],
}) async {
  final uri = Uri(
    scheme: 'mailto',
    path: to,
    queryParameters: {
      if (subject.isNotEmpty) 'subject': subject,
      if (body.isNotEmpty) 'body': body,
      if (cc.isNotEmpty) 'cc': cc.join(','),
      if (bcc.isNotEmpty) 'bcc': bcc.join(','),
    },
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'No se pudo abrir el cliente de email.';
  }
}

