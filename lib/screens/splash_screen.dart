import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../router/router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateToNextScreen();
  }

  bool isLoading = true; // Initial loading status

  Future<String> checkTheUserType(String uid) async {
    try {
      // Query Firestore for the user document with the given UID
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      // Check if the user document exists
      if (userDoc.exists) {
        // Get the value of the 'userType' property
        final String userType = userDoc.data()?['userType'];

        return userType;
      } else {
        // User document does not exist
        print('User document does not exist');
        return 'Unknown';
      }
    } catch (error) {
      print('Error checking user type: $error');
      return 'Unknown';
    }
  }

  Future<void> navigateToNextScreen() async {
    // Delay to simulate a splash screen duration
    await Future.delayed(const Duration(seconds: 3));

    // Check if the user is signed in
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User is not signed in, navigate to login screen
      Navigator.pushReplacementNamed(context, AppRoutes.logIn);
    } else {
      // User is signed in, get the user ID (UID)
      String? uid = user.uid;
      String userType = await checkTheUserType(uid);

      // Navigate based on user type
      if (userType == 'Driver') {
        Navigator.pushReplacementNamed(context, AppRoutes.driverHome);
      } else if (userType == 'Parent') {
        Navigator.pushReplacementNamed(context, AppRoutes.parentHome);
      } else {
        // If userType is unknown or not set, navigate to a default starter screen
        // Navigator.pushReplacementNamed(context, AppRoutes.starterScreen);
      }
    }

    setState(() {
      isLoading = false; // Stop showing loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'Loading',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (isLoading)
            const Column(
              children: [
                CircularProgressIndicator(), // Loading indicator
                SizedBox(height: 16),
                Text(
                  'Please wait...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
