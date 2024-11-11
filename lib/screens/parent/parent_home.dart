import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:school_service/screens/parent/parent_status.dart';
import 'package:school_service/screens/parent/qr_generate.dart'; // Ensure correct import for QR page
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'parent_details.dart';
import 'parent_payment.dart';
import 'parent_chat.dart';
import 'parent_profile.dart';

class ParentHome extends StatefulWidget {
  @override
  _ParentHomeState createState() => _ParentHomeState();
}

class _ParentHomeState extends State<ParentHome> {
  int _selectedIndex = 2; // Default to the home screen
  final User? _currentUser = FirebaseAuth.instance.currentUser; // Retrieve the current user

  // List of pages to navigate to (excluding the home screen, we'll handle it separately)
  final List<Widget> _otherPages = [
    ParentDetails(),
    ParentPayment(),
    ParentChat(),
    ParentProfile(),
  ];

  // Create _buildHomeScreen as an instance method
  Widget _buildHomeScreen(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // First Section - Status
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Color(0xFFFFBF7E),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text and Button Column
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "To see your child live status,",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (_currentUser != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ParentStatus(
                                    userId: _currentUser!.uid, // Use dynamic user ID
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Color(0xFFFFFFFF), // New color added
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), // Smaller padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: Size(100, 36), // Smaller size
                          ),
                          child: Text("Status"),
                        ),
                      ],
                    ),
                  ),
                  // Image
                  Expanded(
                    flex: 2,
                    child: Image.asset('assets/images/card1.png', height: 100),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Second Section - QR Code
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Color(0xFFFFBF7E),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text and Button Column
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Generate your child QR code",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentDetailsPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Color(0xFFFFFFFF), // New color added
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), // Smaller padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: Size(100, 36), // Smaller size
                          ),
                          child: Text("Generate"),
                        ),
                      ],
                    ),
                  ),
                  // Image
                  Expanded(
                    flex: 2,
                    child: Image.asset('assets/images/card2.png', height: 100),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Instructions Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding
            child: Text(
              "1. Click 'Generate' to create the QR code.\n\n"
                  "2. The QR code and details are displayed.\n\n"
                  "3. If you want to edit details, click the Edit \n"
                  "    icon Then save the data.\n\n"
                  "4. The updated QR code is shown.\n\n"
                  "5. You can click the 'Download icon' to save \n"
                  "     the QR code.\n\n"
                  "6. Then print and give it to your child.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.justify, // Justify text
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Set AppBar background color to white
        leading: Padding(
          padding: const EdgeInsets.all(8.0), // Add padding around the logo
          child: Image.asset(
            'assets/images/saferide.png', // Replace with your logo image path
            height: 90, // Adjust the height to make the logo larger
          ),
        ),
      ),
      body: _selectedIndex == 2
          ? _buildHomeScreen(context) // Build home screen if the selected index is 2
          : _otherPages[_selectedIndex < 2 ? _selectedIndex : _selectedIndex - 1], // Handle other pages
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white, // Background of the screen
        color: Color(0xFFFC995E), // Bottom nav bar background color
        buttonBackgroundColor: Color(0xFFFC995E), // Bubble color when selected
        height: 60,
        index: _selectedIndex,
        items: <Widget>[
          Icon(Icons.details_rounded, size: 30, color: Colors.white), // Icon white
          Icon(Icons.payment, size: 30, color: Colors.white), // Icon white
          Icon(Icons.home, size: 30, color: Colors.white), // Icon white
          Icon(Icons.chat, size: 30, color: Colors.white), // Icon white
          Icon(Icons.person, size: 30, color: Colors.white), // Icon white
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
