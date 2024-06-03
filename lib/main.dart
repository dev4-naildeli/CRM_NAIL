import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pusher_beams/pusher_beams.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyD1xcdM6tzjSEJlREfDBwIiaKpfYxWUkN8',
        appId: '1:799365403112:android:3a9aec76c75fde873f945d',
        projectId: 'nailcrm-dee94',
        messagingSenderId: '799365403112',
        storageBucket: 'nailcrm-dee94.appspot.com',
      )
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await PusherBeams.instance.start('18cbc8c2-f217-430f-8363-855b76b0e9ae');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final controller = WebViewController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        // Handle notification when app is in terminated state
        print('Initial message: ${message.messageId}');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // Handle notification when app is brought to foreground from background
      print('Message data: ${message.data}');
    });

    PusherBeams beamsClient = PusherBeams.instance;

    beamsClient.start('18cbc8c2-f217-430f-8363-855b76b0e9ae').then((_) {
      beamsClient.addDeviceInterest('debug-test');
      print("add chanel in device success!!!");
    }).catchError((error) {
      print("Pusher Beams start error: $error");
    });

    beamsClient.onMessageReceivedInTheForeground((noti) {
      print("Received notification: $noti");
    });

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (error) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://crm.naildeli.com'));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              WebViewWidget(
                controller: controller,
              ),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xff0d6efd),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
