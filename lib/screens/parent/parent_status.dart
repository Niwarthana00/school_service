import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParentStatus extends StatelessWidget {
  final String userId;

  ParentStatus({required this.userId});

  final Map<String, String> statusTitles = {
    'morningPickup': 'Morning Pickup',
    'schoolDrop': 'School Drop',
    'schoolPickup': 'School Pickup',
    'homeDrop': 'Home Drop',
  };

  final Map<String, String> statusDescriptions = {
    'morningPickup': 'Your child has been picked up from home.',
    'schoolDrop': 'Your child has arrived at school.',
    'schoolPickup': 'Your child has been picked up from school.',
    'homeDrop': 'Your child has been dropped off at home.',
  };

  bool isStatusCompleted(String currentStatus, String itemStatus) {
    final statusOrder = ['morningPickup', 'schoolDrop', 'schoolPickup', 'homeDrop'];
    final currentIndex = statusOrder.indexOf(currentStatus);
    final itemIndex = statusOrder.indexOf(itemStatus);
    return currentIndex >= itemIndex;
  }

  String getStatusDisplay(String status) {
    switch(status) {
      case 'morningPickup':
        return 'In transit to school';
      case 'schoolDrop':
        return 'At school';
      case 'schoolPickup':
        return 'In transit to home';
      case 'homeDrop':
        return 'At home';
      default:
        return 'Status unknown';
    }
  }

  Color getStatusBackgroundColor(String status) {
    switch(status) {
      case 'schoolDrop':
        return Colors.green[100]!;
      default:
        return Colors.orange[100]!;
    }
  }

  Color getStatusTextColor(String status) {
    switch(status) {
      case 'schoolDrop':
        return Colors.green[800]!;
      default:
        return Colors.orange[800]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFC995E),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Student status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          final currentStatus = userData?['status'] as String? ?? '';
          final profileUrl = userData?['studentProfilePicUrl'] as String?;

          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFFC995E),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Live Status Updates\nChild\'s Journey',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...statusTitles.entries.map((entry) => _buildTimelineItem(
                        context,
                        isCompleted: isStatusCompleted(currentStatus, entry.key),
                        title: entry.value,
                        description: statusDescriptions[entry.key] ?? '',
                      )),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Color(0xFFFED2B7),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: profileUrl != null
                                ? NetworkImage(profileUrl)
                                : AssetImage('assets/images/avatar.png') as ImageProvider,
                          ),
                          SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData?['name'] ?? 'Student Name',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: getStatusBackgroundColor(currentStatus),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Text(
                                      getStatusDisplay(currentStatus),
                                      style: TextStyle(
                                        color: getStatusTextColor(currentStatus),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Stay updated on your child\'s journey to and from school.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(
      BuildContext context, {
        required bool isCompleted,
        required String title,
        required String description,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Color(0xFFFC995E) : Colors.grey[300],
              ),
              child: isCompleted
                  ? Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            Container(
              height: 50,
              width: 2,
              color: isCompleted ? Color(0xFFFC995E) : Colors.grey[300],
            ),
          ],
        ),
        SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isCompleted ? Colors.black : Colors.grey,
              ),
            ),
            SizedBox(height: 5),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isCompleted ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}