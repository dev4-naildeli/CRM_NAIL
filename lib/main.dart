import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final controller = WebViewController();
  @override
  Widget build(BuildContext context) {
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://crm.naildeli.com'));
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          top: true,
          child: WebViewWidget(
            controller: controller,
          ),
        ),
      ),
    );
  }
}
