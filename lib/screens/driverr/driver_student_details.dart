import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_detail_page.dart';

class DriverStudentDetails extends StatefulWidget {
  @override
  _DriverStudentDetailsState createState() => _DriverStudentDetailsState();
}

class _DriverStudentDetailsState extends State<DriverStudentDetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<Student>> _students;
  List<Student> _allStudents = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _students = fetchStudents();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<List<Student>> fetchStudents() async {
    List<Student> studentList = [];

    try {
      QuerySnapshot snapshot = await _firestore.collection('users')
          .where('userType', isEqualTo: 'Parent')
          .get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        studentList.add(Student(
          fullName: data['fullName'] ?? 'Unknown',
          address: data['address'] ?? 'No address provided',
          phoneNumber: data['phoneNumber'] ?? 'Not available',
          grade: data['grade'] ?? 'Not specified',
          parentName: data['name'] ?? 'Unknown',
          profilePicUrl: data['studentProfilePicUrl'] ?? '',
        ));
      }

      _allStudents = studentList;
      return studentList;
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
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
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFE6D9),
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4.0,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                ),
              ),
            ),
            SizedBox(height: 20),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentDetailPage(
                                imageUrl: student.profilePicUrl,
                                studentName: student.fullName,
                                address: student.address,
                                phone: student.phoneNumber,
                                parentName: student.parentName,
                                grade: student.grade,
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
        contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        leading: CircleAvatar(
          radius: 20.0,
          backgroundImage: student.profilePicUrl.isNotEmpty
              ? NetworkImage(student.profilePicUrl)
              : AssetImage('assets/images/avatar.png') as ImageProvider,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                student.fullName,
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
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
            Icon(Icons.location_on, size: 14.0, color: Colors.black26),
            SizedBox(width: 4.0),
            Expanded(
              child: Text(
                student.address,
                style: TextStyle(
                  fontSize: 10.0,
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

class Student {
  final String fullName;
  final String address;
  final String phoneNumber;
  final String grade;
  final String parentName;
  final String profilePicUrl;

  Student({
    required this.fullName,
    required this.address,
    required this.phoneNumber,
    required this.grade,
    required this.parentName,
    required this.profilePicUrl,
  });
}