// routes.dart
import 'package:flutter/material.dart';
import 'package:school_service/screens/driverr/driver_home.dart';
import 'package:school_service/screens/parent/parent_home.dart';

import '../screens/login.dart';
import '../screens/signup_screen.dart';

class AppRoutes {
  static const String driverHome = '/driverHome';
  static const String parentHome = '/parentHome';
  static const String logIn = '/logIn';
  static const String signUp = '/signUp';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      
      case driverHome:
        return MaterialPageRoute(builder: (_) => DriverHome());
      case parentHome:
        return MaterialPageRoute(builder: (_) => ParentHome());
      case logIn:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => SignupScreen());
     
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
