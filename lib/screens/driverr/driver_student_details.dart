import 'package:flutter/material.dart';
import 'student_detail_page.dart'; // Import the detail page

class DriverStudentDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student List'),
        backgroundColor: Color(0xFFFC995E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFE6D9), // Updated background color
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4.0,
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Student Card
            GestureDetector(
              onTap: () {
                // Navigate to student detail page when tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentDetailPage(
                      imageUrl: 'assets/images/avatar.png',
                      studentName: 'Niwarthana sathyanjali',
                      grade: 'Grade 11',
                      address: 'No: 50/1, Temple road, Colombo.',
                      phone: '0777777777',
                      parentName: 'Madushika sadamali',
                    ),
                  ),
                );
              },
              child: StudentCard(),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          radius: 20.0, // Reduced image size
          backgroundImage: AssetImage('assets/images/avatar.png'), // Add your avatar image path here
        ),
        title: Row(
          children: [
            Text(
              'Niwarthana sathyanjali',
              style: TextStyle(
                fontSize: 12.0, // Reduced text size
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.0),
            Text(
              'Active',
              style: TextStyle(
                fontSize: 10.0,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Icon(Icons.location_on, size: 14.0, color: Colors.black26), // Location icon
            SizedBox(width: 4.0),
            Expanded(
              child: Text(
                'No: 50/1, Temple road, Colombo.',
                style: TextStyle(
                  fontSize: 10.0, // Reduced address font size
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}
