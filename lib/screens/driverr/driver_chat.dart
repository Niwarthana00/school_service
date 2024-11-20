import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'IndividualDriverChat.dart';

class DriverChat extends StatefulWidget {
  @override
  _DriverChatState createState() => _DriverChatState();
}

class _DriverChatState extends State<DriverChat> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  List<Student> studentList = [];
  List<Student> filteredStudentList = [];
  TextEditingController _searchController = TextEditingController();
  Map<String, int> unreadMessageCounts = {};

  @override
  void initState() {
    super.initState();
    _fetchUnreadMessageCounts();
  }

  void _fetchUnreadMessageCounts() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    QuerySnapshot messagesSnapshot = await _firestore
        .collection('messages')
        .where('receiverEmail', isEqualTo: currentUser.email)
        .where('isRead', isEqualTo: false)
        .get();

    setState(() {
      unreadMessageCounts = {};
      for (var doc in messagesSnapshot.docs) {
        String senderEmail = doc['senderEmail'];
        unreadMessageCounts[senderEmail] =
            (unreadMessageCounts[senderEmail] ?? 0) + 1;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  filteredStudentList = studentList
                      .where((student) =>
                      student.fullName.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              },
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

          studentList = snapshot.data!.docs.map((doc) {
            return Student(
              fullName: doc['fullName'] ?? 'Unknown',
              address: doc['address'] ?? 'N/A',
              phoneNumber: doc['phoneNumber'] ?? 'N/A',
              grade: doc['grade'] ?? 'N/A',
              parentName: doc['name'] ?? 'N/A',
              profilePicUrl: doc.data().toString().contains('studentProfilePicUrl')
                  ? doc['studentProfilePicUrl']
                  : '',
              email: doc['email'] ?? 'N/A',
            );
          }).toList();

          var displayList = filteredStudentList.isNotEmpty ? filteredStudentList : studentList;

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              var student = displayList[index];
              int unreadCount = unreadMessageCounts[student.email] ?? 0;

              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IndividualDriverChat(
                            email: student.email,
                          ),
                        ),
                      );
                    },
                    child: ChatListTile(
                      name: student.fullName,
                      lastMessage: student.phoneNumber,
                      timestamp: student.phoneNumber,
                      profilePicUrl: student.profilePicUrl,
                      unreadMessageCount: unreadCount,
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
  final String profilePicUrl;
  final int unreadMessageCount;

  ChatListTile({
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.profilePicUrl,
    this.unreadMessageCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: _getProfileImage(),
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
          unreadMessageCount > 0
              ? CircleAvatar(
            radius: 10,
            backgroundColor: Colors.red,
            child: Text(
              unreadMessageCount.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
              : CircleAvatar(
            radius: 6,
            backgroundColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  ImageProvider _getProfileImage() {
    if (profilePicUrl != null && profilePicUrl.isNotEmpty) {
      try {
        return NetworkImage(profilePicUrl);
      } catch (e) {
        return AssetImage('assets/images/avatar.png');
      }
    }
    return AssetImage('assets/images/avatar.png');
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
    required this.email,
  });
}