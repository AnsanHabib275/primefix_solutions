import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HostedCheckoutWebView extends StatefulWidget {
  final String postUrl;
  final Map<String, String> fields;
  final String successUrlPrefix; // Return URL set by server (we watch for it)
  const HostedCheckoutWebView({super.key, required this.postUrl, required this.fields, required this.successUrlPrefix});

  @override
  State<HostedCheckoutWebView> createState() => _HostedCheckoutWebViewState();
}

class _HostedCheckoutWebViewState extends State<HostedCheckoutWebView> {
  late final WebViewController controller;
  bool completed = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (req) {
          if (req.url.startsWith(widget.successUrlPrefix)) {
            if (!completed) {
              completed = true;
              Navigator.of(context).pop(true);
            }
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ));
    _loadAutoSubmitForm();
  }

  Future<void> _loadAutoSubmitForm() async {
    final inputs = widget.fields.entries.map((e) =>
      '<input type="hidden" name="${htmlEscape.convert(e.key)}" value="${htmlEscape.convert(e.value)}" />').join();
    final html = '''
<!DOCTYPE html><html><body onload="document.forms[0].submit()">
<p>Redirecting to payment...</p>
<form method="POST" action="${htmlEscape.convert(widget.postUrl)}">
$inputs
<noscript><button type="submit">Continue</button></noscript>
</form></body></html>
''';
    await controller.loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Secure Checkout')), body: WebViewWidget(controller: controller));
  }
}
