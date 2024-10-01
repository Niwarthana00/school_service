import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'student_detail_page.dart'; // Import the detail page

class DriverStudentDetails extends StatefulWidget {
  @override
  _DriverStudentDetailsState createState() => _DriverStudentDetailsState();
}

class _DriverStudentDetailsState extends State<DriverStudentDetails> {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<Student>> _students;
  List<Student> _allStudents = []; // Store all students for filtering
  String _searchQuery = ''; // Store the search query
  final TextEditingController _searchController = TextEditingController(); // Search text controller

  @override
  void initState() {
    super.initState();
    // Fetch the students data when the widget initializes
    _students = fetchStudents();

    // Listener for the search text input
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text; // Update the search query
      });
    });
  }

  Future<List<Student>> fetchStudents() async {
    List<Student> studentList = [];

    // Query the Firestore collection for users with userType 'Parent'
    QuerySnapshot snapshot = await _firestore.collection('users')
        .where('userType', isEqualTo: 'Parent')
        .get();

    // Create Student objects from the fetched documents
    for (var doc in snapshot.docs) {
      studentList.add(Student(
        fullName: doc['fullName'],
        address: doc['address'],
        phoneNumber: doc['phoneNumber'] ?? 'N/A', // Updated field name to phoneNumber
        grade: doc['grade'] ?? 'N/A', // Added grade field
        parentName: doc['name'] ?? 'N/A', // Fetch parent name from 'name' field
        profilePicUrl: doc['studentProfilePicUrl'] ?? '', // Fetch student profile picture URL
      ));
    }

    _allStudents = studentList; // Store all students for filtering
    return studentList;
  }

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
                controller: _searchController, // Set the controller
                decoration: InputDecoration(
                  hintText: 'Search by name',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Student List
            Expanded(
              child: FutureBuilder<List<Student>>(
                future: _students,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No parents found.'));
                  }

                  // Display the filtered list of students
                  List<Student> students = snapshot.data!;
                  List<Student> filteredStudents = students.where((student) {
                    return student.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to student detail page when tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentDetailPage(
                                imageUrl: student.profilePicUrl, // Use student's profile picture URL
                                studentName: student.fullName,
                                address: student.address,
                                phone: student.phoneNumber, // Updated to phoneNumber
                                parentName: student.parentName, // Pass parentName to detail page
                                grade: student.grade, // Passing grade to the detail page
                              ),
                            ),
                          );
                        },
                        child: StudentCard(student: student),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final Student student;

  StudentCard({required this.student});

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
          backgroundImage: student.profilePicUrl.isNotEmpty
              ? NetworkImage(student.profilePicUrl) // Use NetworkImage if URL is present
              : AssetImage('assets/images/avatar.png') as ImageProvider, // Fallback to static avatar image
        ),
        title: Row(
          children: [
            Text(
              student.fullName,
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 14.0, color: Colors.black26), // Location icon
                SizedBox(width: 4.0),
                Expanded(
                  child: Text(
                    student.address,
                    style: TextStyle(
                      fontSize: 10.0, // Reduced address font size
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.0),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}

// Student model class
class Student {
  final String fullName;
  final String address;
  final String phoneNumber; // Updated field name to phoneNumber
  final String grade; // Added grade field
  final String parentName; // Added parentName field
  final String profilePicUrl; // Added profilePicUrl field

  Student({
    required this.fullName,
    required this.address,
    required this.phoneNumber,
    required this.grade, // Added grade to constructor
    required this.parentName, // Added parentName to constructor
    required this.profilePicUrl, // Added profilePicUrl to constructor
  });
}
