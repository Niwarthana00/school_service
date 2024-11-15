import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ParentChat extends StatefulWidget {
  @override
  _ParentChatState createState() => _ParentChatState();
}

class _ParentChatState extends State<ParentChat> {
  final _messageController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  void _sendMessage() async {
    final user = _auth.currentUser;
    if (user != null && _messageController.text.trim().isNotEmpty) {
      await _firestore.collection('chats').doc('chatRoom').collection(user.email.toString()).add({
        'text': _messageController.text,
        'type': "parent",
        'timestamp': FieldValue.serverTimestamp()
      });
      _messageController.clear();
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
        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message['type'] == "parent";
            return isMe
                ? buildSentMessage(
                message['text'],
                message['timestamp']?.toDate().toString() ?? "")
                : buildReceivedMessage(
                message['text'],
                message['timestamp']?.toDate().toString() ?? "");
          },
        );
      },
    );
  }

  Widget buildSentMessage(String message, String time) {
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
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFFC995E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(color: Colors.white, fontSize: 16),
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

  Widget buildReceivedMessage(String message, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundImage: AssetImage('assets/images/avatar.png'), // Use your own avatar image here
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
                    borderRadius: BorderRadius.circular(16),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          buildMessageInputField(),
        ],
      ),
    );
  }

  Widget buildMessageInputField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(hintText: "Write your message", border: InputBorder.none),
            ),
          ),
          IconButton(icon: Icon(Icons.send, color: Color(0xFFFC995E)), onPressed: _sendMessage),
        ],
      ),
    );
  }
}
