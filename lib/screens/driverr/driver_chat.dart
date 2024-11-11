import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'IndividualDriverChat.dart';

class DriverChat extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFD8C0), Color(0xFFFC995E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [Color(0xFFFFA726), Color(0xFFFC995E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFFFE6D9),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                hintText: 'Search',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').where('userType', isEqualTo: 'Parent').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var studentList = snapshot.data!.docs.map((doc) {
            return Student(
              fullName: doc['fullName'],
              address: doc['address'],
              phoneNumber: doc['phoneNumber'] ?? 'N/A',
              grade: doc['grade'] ?? 'N/A',
              parentName: doc['name'] ?? 'N/A',
              profilePicUrl: doc['studentProfilePicUrl'] ?? '',
              email: doc['email'], // Ensure email is included in the doc
            );
          }).toList();

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: studentList.length,
            itemBuilder: (context, index) {
              var student = studentList[index];
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigate to IndividualDriverChat and pass the email
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IndividualDriverChat(
                            email: student.email, // Pass the email to the chat page
                          ),
                        ),
                      );
                    },
                    child: ChatListTile(
                      name: student.fullName,
                      lastMessage: student.phoneNumber, // Placeholder
                      timestamp: student.phoneNumber, // Placeholder
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    color: Colors.grey.shade300,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class ChatListTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String timestamp;

  ChatListTile({
    required this.name,
    required this.lastMessage,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage('assets/images/avatar.png'),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            timestamp,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(height: 4),
          CircleAvatar(
            radius: 6,
            backgroundColor: Colors.grey.shade300,
          ),
        ],
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
  final String email;

  Student({
    required this.fullName,
    required this.address,
    required this.phoneNumber,
    required this.grade,
    required this.parentName,
    required this.profilePicUrl,
    required this.email, // Added email
  });
}
