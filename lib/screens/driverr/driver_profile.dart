import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase import for logout
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'package:school_service/screens/login.dart';
import 'dart:ui' as ui;

class DriverProfile extends StatefulWidget {
  @override
  _DriverProfileState createState() => _DriverProfileState();
}

class _DriverProfileState extends State<DriverProfile> {
  // Variable to hold the driver data
  Map<String, dynamic>? driverData;

  @override
  void initState() {
    super.initState();
    _fetchDriverData();
  }

  // Fetch driver data from Firestore
  Future<void> _fetchDriverData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid) // Assuming user document ID is their UID
            .get();

        if (driverSnapshot.exists) {
          setState(() {
            driverData = driverSnapshot.data() as Map<String, dynamic>?;
          });
        }
      }
    } catch (e) {
      print("Error fetching driver data: $e");
    }
  }

  // Function to handle logout
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Navigate to LoginScreen after signing out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: driverData == null
          ? Center(child: CircularProgressIndicator()) // Show loading while data is fetched
          : SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Curved background with an image
                ClipPath(
                  clipper: CurvedHeaderClipper(),
                  child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/orange.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Profile image with SafeRide logo and text
                Positioned(
                  top: 170, // Position the avatar above the curve
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person,
                            size: 50, color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      Text(
                        driverData?['fullName'] ?? 'Driver Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Details Section
            Container(
              width: double.infinity, // Make container full width
              color: Color(0xFFFADDC4), // Background color for "Details"
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Left-right padding
              alignment: Alignment.centerLeft, // Align text to the left
              child: Text(
                'Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Black text color
                ),
              ),
            ),

            // Driver details list
            ListTile(
              leading: Icon(Icons.person),
              title: Text(driverData?['fullName'] ?? 'Full Name'),
              trailing: Icon(Icons.edit),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text(driverData?['address'] ?? 'Address'),
              trailing: Icon(Icons.edit),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text(driverData?['phoneNumber'] ?? 'Phone Number'),
              trailing: Icon(Icons.edit),
            ),
            ListTile(
              leading: Icon(Icons.directions_car),
              title: Text(driverData?['vehicleNumber'] ?? 'Vehicle Number'),
              trailing: Icon(Icons.edit),
            ),

            SizedBox(height: 20),

            // Content Section
            Container(
              width: double.infinity, // Make container full width
              color: Color(0xFFFADDC4), // Background color for "Content"
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Left-right padding
              alignment: Alignment.centerLeft, // Align text to the left
              child: Text(
                'Content',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Black text color
                ),
              ),
            ),

            // Download Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Download'),
                onTap: () {},
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () => _logout(context), // Calls the logout function
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Clipper to create the curved header
class CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 80);

    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 80);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  runApp(MaterialApp(home: DriverProfile()));
}
