import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'driver_chat.dart';
import 'driver_profile.dart';
import 'driver_student_details.dart';
import 'qr_scanner.dart';

class DriverHome extends StatefulWidget {
  @override
  _DriverHomeState createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  int _currentIndex = 2; // Home is at the center of the Bottom Navigation
  final List<Widget> _pages = [
    QRScanner(),
    DriverStudentDetails(),
    DriverHomeScreen(),
    DriverChat(),
    DriverProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        title: Image.asset(
          'assets/images/saferide.png',
          height: 40,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60.0,
        backgroundColor: Colors.transparent,
        color: Color(0xFFFC995E),
        buttonBackgroundColor: Color(0xFFFC995E),
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        items: <Widget>[
          Icon(Icons.qr_code, size: 30, color: Colors.white),
          Icon(Icons.people, size: 30, color: Colors.white),
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.chat, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class DriverHomeScreen extends StatefulWidget {
  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _statusSteps = [
    {"label": "Picked Up", "icon": Icons.check_circle},
    {"label": "At School", "icon": Icons.home},
    {"label": "Arrived", "icon": Icons.school},
    {"label": "Ended", "icon": Icons.location_on},
  ];

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to change the student status?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                setState(() {
                  // Change the status only if 'Yes' is pressed
                  if (_currentStep < _statusSteps.length - 1) {
                    _currentStep++;
                  } else {
                    _currentStep = -1; // Reset to -1 to indicate no status
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            _buildStatusBar(),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog();
                },
                child: Text(
                  _currentStep >= 0 && _currentStep < _statusSteps.length - 1
                      ? _statusSteps[_currentStep + 1]["label"]
                      : "Start Trip", // Display next status or "Trip Ended"
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFC995E),
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                  minimumSize: Size(230, 50), // Set a larger width and height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0), // Remove curvature
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text("Ensure all students scan their QR codes!",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Center(
              child: Image.asset('assets/images/scanner.gif', height: 200),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle QR scan button press
                },
                child: Text("SCAN", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFC995E),
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            _buildInstructions(),
            SizedBox(height: 20),
             _imageCarousel(),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "How to scan the QR",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 10),
        Text("1. Hold the QR code steady in front of the \n"
            "    scanner.\n"),
        Text("2. Ensure the code is clearly visible in the\n "
            "    frame.\n"),
        Text("3. Check the child's details after scanning.\n"),
        Text("4. Adjust the distance if the scan doesn't work.\n"),
        Text("5. Repeat the process for each child."),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _currentStep >= 0
              ? (_currentStep + 1) / _statusSteps.length
              : 0.0,
          backgroundColor: Color(0xFFFAD7C5),
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFC995E)),
          minHeight: 8,
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _statusSteps.map((step) {
            int index = _statusSteps.indexOf(step);
            return _buildStatusIcon(step["icon"], step["label"], index);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(IconData icon, String label, int index) {
    bool isActive = index == _currentStep;

    return Column(
      mainAxisSize:
          MainAxisSize.min, // Use minimum size to prevent excess space
      children: [
        Icon(
          icon,
          color: isActive ? Color(0xFF7D4F1F) : Colors.grey,
          size: 30,
        ),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0), // Add some padding
          child: Text(
            label,
            textAlign: TextAlign.center, // Center-align the text
            style: TextStyle(
              color: isActive ? Color(0xFF7D4F1F) : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _imageCarousel() {
    final List<String> imgList = [
      'assets/images/how_to_scan_qr1.png',
      'assets/images/how_to_scan_qr2.png',
      'assets/images/how_to_scan_qr3.png',
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 150.0,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
      ),
      items: imgList
          .map((item) => Container(
                child: Center(
                  child: Image.asset(item, fit: BoxFit.cover, width: 1000),
                ),
              ))
          .toList(),
    );
  }
}
