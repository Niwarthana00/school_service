import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:school_service/providers/auth_provider.dart';
import 'package:school_service/screens/splash_screen.dart';
import 'package:school_service/services/notification_service.dart';
import 'firebase_options.dart';
import 'router/router.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase Messaging setup
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request notification permissions
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }

  final notificationService = NotificationService();
  try {
    await notificationService.initializeMessaging();
  } catch (e) {
    print('Failed to initialize notification service: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), // Initialize AuthProvider
      ],
      child: MaterialApp(
        onGenerateRoute: AppRoutes.generateRoute,
        title: 'School Service App',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: NotificationHandler(child: SplashScreen()), // Wrap SplashScreen with NotificationHandler
      ),
    );
  }
}

// NotificationHandler widget to listen for foreground and background notifications
class NotificationHandler extends StatefulWidget {
  final Widget child;

  NotificationHandler({required this.child});

  @override
  _NotificationHandlerState createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler> {
  @override
  void initState() {
    super.initState();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.notification?.title}');
      if (message.notification != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(message.notification!.title ?? 'No Title'),
            content: Text(message.notification!.body ?? 'No Body'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    });

    // Handle messages when app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened from terminated state: ${message.notification?.title}');
      if (message.data['route'] != null) {
        Navigator.pushNamed(context, message.data['route']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
