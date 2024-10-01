import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package

class StudentDetailPage extends StatelessWidget {
  final String imageUrl;
  final String studentName;
  final String grade;
  final String address;
  final String phone;
  final String parentName;

  StudentDetailPage({
    required this.imageUrl,
    required this.studentName,
    required this.grade,
    required this.address,
    required this.phone,
    required this.parentName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top section with gradient and avatar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFD8B0), // Lighter shade to complement #FC995E
                  Color(0xFFFC995E), // Main gradient color
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
            child: Column(
              children: [
                // AppBar content
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      'Student Details',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.more_vert, color: Colors.transparent), // To keep the title centered
                  ],
                ),

                // Circle avatar
                CircleAvatar(
                  radius: 50.0,
                  backgroundImage: AssetImage(imageUrl), // Use NetworkImage for network images
                ),
                SizedBox(height: 10),
              ],
            ),
          ),

          // Rest of the details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Student Details
                  DetailRow(label: 'Student name', value: studentName),
                  DetailRow(label: 'Grade', value: grade),
                  DetailRow(label: 'Address', value: address),
                  DetailRow(label: 'Phone', value: phone),
                  DetailRow(label: 'Parent name', value: parentName),

                  SizedBox(height: 20),

                  // Contact actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.message, color: Color(0xFFFC995E)),
                        onPressed: () {
                          // Handle message action
                        },
                        iconSize: 40.0,
                      ),
                      IconButton(
                        icon: Icon(Icons.phone, color: Color(0xFFFC995E)),
                        onPressed: () {
                          // Handle phone action - launch dialer
                          _launchCaller(phone);
                        },
                        iconSize: 40.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to launch the dialer
  void _launchCaller(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }
}

// Reusable Widget for displaying student details
class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            '$label',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          // Value slightly below the label
          SizedBox(height: 4.0), // Adjust the gap between label and value
          Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey.shade700,
            ),
          ),
          Divider(
            thickness: 1,
            color: Colors.grey.shade300, // Divider between the rows
          ),
        ],
      ),
    );
  }
}
