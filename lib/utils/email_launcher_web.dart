// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> composeEmail({
  required String to,
  String subject = '',
  String body = '',
  List<String> cc = const [],
  List<String> bcc = const [],
}) async {
  final params = <String, String>{};
  if (subject.isNotEmpty) params['subject'] = subject;
  if (body.isNotEmpty) params['body'] = body;
  if (cc.isNotEmpty) params['cc'] = cc.join(',');
  if (bcc.isNotEmpty) params['bcc'] = bcc.join(',');
  final uri = Uri(
    scheme: 'mailto',
    path: to,
    query: params.isEmpty
        ? null
        : params.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&'),
  );
  html.window.location.href = uri.toString();
}

