import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class IndividualDriverChat extends StatefulWidget {
  final String email;

  IndividualDriverChat({required this.email});

  @override
  _IndividualDriverChatState createState() => _IndividualDriverChatState();
}

class _IndividualDriverChatState extends State<IndividualDriverChat> {
  final _messageController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  String? studentProfilePicUrl;
  String? studentName;

  @override
  void initState() {
    super.initState();
    _getStudentProfileInfo();
  }

  void _getStudentProfileInfo() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.email).get();
      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          studentProfilePicUrl = userDoc['studentProfilePicUrl'] ?? '';
          studentName = userDoc['fullName'] ?? 'Student';
        });
      }
    } catch (e) {
      print("Error fetching profile information: $e");
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await _firestore.collection('chats').doc('chatRoom').collection(widget.email).add({
        'text': _messageController.text.trim(),
        'type': "driver",
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showDeleteConfirmationDialog(DocumentSnapshot message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Message'),
          content: Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteMessage(message);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage(DocumentSnapshot message) async {
    try {
      await _firestore
          .collection('chats')
          .doc('chatRoom')
          .collection(widget.email)
          .doc(message.id)
          .delete();
    } catch (e) {
      print("Error deleting message: $e");
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) {
      return '';
    }
    final format = DateFormat('h:mm a');
    return format.format(time);
  }

  Widget _buildMessages() {
    return StreamBuilder(
      stream: _firestore
          .collection('chats')
          .doc('chatRoom')
          .collection(widget.email)
          .orderBy('timestamp')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data?.docs ?? [];
        Map<String, List<DocumentSnapshot>> groupedMessages = {};

        // Group messages by date
        for (var message in messages) {
          DateTime? messageDate = message['timestamp']?.toDate();
          String dateKey = _formatDate(messageDate);
          groupedMessages.putIfAbsent(dateKey, () => []).add(message);
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: groupedMessages.length,
          itemBuilder: (context, dateIndex) {
            String dateKey = groupedMessages.keys.toList()[dateIndex];
            List<DocumentSnapshot> dailyMessages = groupedMessages[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display date in the center
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      dateKey,
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                // Display messages for that date
                ...dailyMessages.map((message) {
                  final isMe = message['type'] == "driver";
                  final messageDate = message['timestamp']?.toDate();
                  return isMe
                      ? GestureDetector(
                    onLongPress: () => _showDeleteConfirmationDialog(message),
                    child: _buildSentMessage(message['text'], messageDate),
                  )
                      : _buildReceivedMessage(message['text'], messageDate);
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProfileAvatar({double radius = 20}) {
    if (studentProfilePicUrl != null && studentProfilePicUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(studentProfilePicUrl!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: radius,
      ),
    );
  }

  Widget _buildSentMessage(String message, DateTime? time) {
    String timeString = _formatTime(time);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 250),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFFC995E),
                    borderRadius: BorderRadius.circular(100), // Increased curve
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  timeString,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedMessage(String message, DateTime? time) {
    String timeString = _formatTime(time);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileAvatar(radius: 15),
          SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 250),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(100), // Increased curve
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  timeString,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Write your message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Color(0xFFFC995E),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            _buildProfileAvatar(radius: 20),
            SizedBox(width: 10),
            Text(studentName ?? 'Chat'),
          ],
        ),
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          _buildMessageInputField(),
        ],
      ),
    );
  }
}
