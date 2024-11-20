import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'package:school_service/providers/auth_provider.dart'; // Import AuthProvider
import 'package:school_service/screens/AccountPickerPage.dart';
import 'package:school_service/screens/driverr/driver_home.dart';
import 'package:school_service/screens/splash_screen.dart';
import 'package:school_service/screens/start.dart';

import 'router/router.dart';
import 'screens/parent/parent_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
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
        home: SplashScreen(),
        // home: DriverHome(),
        // Set StartScreen as the home
      ),
    );
  }
}

