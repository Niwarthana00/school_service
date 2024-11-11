import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  int _currentIndex = 2;
  final List<Widget> _pages = [
    QRScannerScreen(),
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isUpdating = false;

  Future<void> _updateParentStatus() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      QuerySnapshot statusCheckSnapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'Parent')
          .get();

      bool hasValidStudents = statusCheckSnapshot.docs.any(
              (doc) => doc['status'] == 'morningPickup');

      if (!hasValidStudents) {
        _showResultDialog(
          false,
          'Invalid Status',
          'No students found with morning pickup status. Please make sure students have been picked up first.',
        );
        return;
      }

      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'Parent')
          .where('status', isEqualTo: 'morningPickup')
          .get();

      WriteBatch batch = _firestore.batch();
      querySnapshot.docs.forEach((doc) {
        batch.update(doc.reference, {'status': 'schoolDrop'});
      });

      await batch.commit();

      _showResultDialog(
        true,
        'Status Updated Successfully',
        'All students have been marked as dropped at school.',
      );
    } catch (e) {
      _showResultDialog(
        false,
        'Error',
        'Failed to update status: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Confirm School Drop',
            style: TextStyle(
              color: Color(0xFFFC995E),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to mark all students as dropped at school?',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Color(0xFFFC995E),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _updateParentStatus();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showResultDialog(bool success, String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
                size: 30,
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: success ? Colors.green : Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: success ? Colors.green : Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: Colors.white,
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
            Text(
              "Ensure all students scan their QR codes!",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Image.asset(
                'assets/images/scanner.gif',
                height: 200,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRScannerScreen()),
                  );
                },
                child: Text(
                  "SCAN",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFC995E),
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  elevation: 2,
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _isUpdating ? null : _showConfirmationDialog,
                child: _isUpdating
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  "Drop school",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFC995E),
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  elevation: 2,
                ),
              ),
            ),
            SizedBox(height: 20),
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
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How to scan the QR",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFFFC995E),
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Instruct students to scan the QR code at the entrance of the van. "
                "Ensure that each student's status updates accordingly. Regular updates help ensure all students are accounted for.",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _imageCarousel() {
    return CarouselSlider(
      items: [
        Image.asset("assets/images/1.png"),
        Image.asset("assets/images/2.png"),
        Image.asset("assets/images/3.png"),
      ],
      options: CarouselOptions(
        height: 200,
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
    );
  }
}
