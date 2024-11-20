import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'DriverProfileDialog.dart';

class ParentChat extends StatefulWidget {
  @override
  _ParentChatState createState() => _ParentChatState();
}

class _ParentChatState extends State<ParentChat> {
  final _messageController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String? _driverImageUrl;
  String? _driverPhoneNumber;

  @override
  void initState() {
    super.initState();
    _getDriverDetails();
  }

  Future<void> _getDriverDetails() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'Driver')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _driverImageUrl = querySnapshot.docs.first.data()['profileImageUrl'];
          _driverPhoneNumber = querySnapshot.docs.first.data()['phoneNumber'];
        });
      }
    } catch (e) {
      print('Error fetching driver details: $e');
    }
  }

  void _sendMessage() async {
    final user = _auth.currentUser;
    if (user != null && _messageController.text.trim().isNotEmpty) {
      await _firestore
          .collection('chats')
          .doc('chatRoom')
          .collection(user.email.toString())
          .add({
        'text': _messageController.text,
        'type': "parent",
        'timestamp': FieldValue.serverTimestamp()
      });
      _messageController.clear();
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('chats')
            .doc('chatRoom')
            .collection(user.email.toString())
            .doc(messageId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message deleted successfully')),
        );
      } catch (e) {
        print('Error deleting message: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete message')),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(String messageId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Message'),
          content: Text('Do you want to delete this message?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMessage(messageId);
              },
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('HH:mm').format(timestamp.toDate());
  }

  String _formatMessageDate(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final messageDate = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    if (messageDate.isAfter(today)) {
      return 'Today';
    } else if (messageDate.isAfter(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('dd/MM/yyyy').format(messageDate);
    }
  }

  Widget _buildMessages() {
    final user = _auth.currentUser;
    if (user == null) {
      return Center(child: Text("Please log in to see messages."));
    }

    return StreamBuilder(
      stream: _firestore
          .collection('chats')
          .doc('chatRoom')
          .collection(user.email.toString())
          .orderBy('timestamp')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final messages = snapshot.data?.docs ?? [];

        final groupedMessages = <String, List<QueryDocumentSnapshot>>{};
        for (var message in messages) {
          final timestamp = message['timestamp'] as Timestamp?;
          final dateKey = _formatMessageDate(timestamp);
          if (!groupedMessages.containsKey(dateKey)) {
            groupedMessages[dateKey] = [];
          }
          groupedMessages[dateKey]!.add(message);
        }

        return ListView.builder(
          reverse: true,
          itemCount: groupedMessages.length,
          itemBuilder: (context, dateIndex) {
            final dateKey = groupedMessages.keys.toList().reversed.toList()[dateIndex];
            final dateMsgs = groupedMessages[dateKey]!;

            return Column(
              children: [
                // Date separator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    dateKey,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Messages for this date
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  reverse: true,
                  itemCount: dateMsgs.length,
                  itemBuilder: (context, msgIndex) {
                    final message = dateMsgs.reversed.toList()[msgIndex];
                    final isMe = message['type'] == "parent";
                    return isMe
                        ? buildSentMessage(
                      message['text'],
                      _formatTimestamp(message['timestamp'] as Timestamp?),
                      message.id,
                    )
                        : buildReceivedMessage(
                        message['text'],
                        _formatTimestamp(message['timestamp'] as Timestamp?));
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Sent message widget
  Widget buildSentMessage(String message, String time, String messageId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onLongPress: () => _showDeleteConfirmation(messageId),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFFC995E),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      message,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Received message widget
  Widget buildReceivedMessage(String message, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_driverImageUrl != null)
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => DriverProfileDialog(),
                );
              },
              child: CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(_driverImageUrl!),
              ),
            ),
          SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to launch phone dialer
  void _launchPhone() async {
    if (_driverPhoneNumber != null && await canLaunch('tel:$_driverPhoneNumber')) {
      await launch('tel:$_driverPhoneNumber');
    } else {
      throw 'Could not launch phone dialer';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white, // Set the background color to white
        actions: [
          IconButton(
            icon: Icon(Icons.call, color: Color(0xFFFC995E)), // Call icon in orange color
            onPressed: _launchPhone, // Launch phone dialer
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          buildMessageInputField(),
        ],
      ),
    );
  }

  // Input field for sending messages
  Widget buildMessageInputField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Write your message",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
              maxLines: null,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Color(0xFFFC995E)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
