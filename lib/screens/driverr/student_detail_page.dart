import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: Text('Student Details'),
        backgroundColor: Color(0xFFFC995E),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back when arrow is pressed
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture with Gradient Background
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.orange.shade200, Colors.orange.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(8.0), // Gradient padding around the avatar
              child: CircleAvatar(
                radius: 50.0,
                backgroundColor: Colors.transparent, // Ensure transparency for the image
                backgroundImage: AssetImage(imageUrl), // Update this to NetworkImage if using URLs
              ),
            ),
            SizedBox(height: 20),

            // Student Details
            DetailRow(label: 'Student name', value: studentName),
            DetailRow(label: 'Grade', value: grade),
            DetailRow(label: 'Address', value: address),
            DetailRow(label: 'Phone', value: phone),
            DetailRow(label: 'Parent name', value: parentName),

            SizedBox(height: 20),


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
                  icon: Icon(Icons.phone, color:Color(0xFFFC995E)),
                  onPressed: () {
                    // Handle phone action
                  },
                  iconSize: 40.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
