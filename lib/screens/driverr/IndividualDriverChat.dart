import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IndividualDriverChat extends StatefulWidget {
  final String email;

  IndividualDriverChat({required this.email});

  @override
  _IndividualDriverChatState createState() => _IndividualDriverChatState();
}

class _IndividualDriverChatState extends State<IndividualDriverChat> {
  final _messageController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  // Function to send message to Firestore
  void _sendMessage() async {
    await _firestore.collection('chats').doc('chatRoom').collection(widget.email).add({
      'text': _messageController.text,
      'type': "driver",  // Assuming 'driver' as the user type
      'timestamp': FieldValue.serverTimestamp(),
    });
    _messageController.clear();
  }

  // Build the chat messages
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
        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message['type'] == "driver";
            return isMe
                ? _buildSentMessage(message['text'], message['timestamp']?.toDate().toString() ?? "")
                : _buildReceivedMessage(message['text'], message['timestamp']?.toDate().toString() ?? "");
          },
        );
      },
    );
  }

  // Widget for sent messages
  Widget _buildSentMessage(String message, String time) {
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

  // Widget for received messages
  Widget _buildReceivedMessage(String message, String time) {
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

  // Build the entire chat screen UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),  // Display chat messages
          _buildMessageInputField(),  // Input field for new messages
        ],
      ),
    );
  }

  // Widget for the message input field
  Widget _buildMessageInputField() {
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
          IconButton(
            icon: Icon(Icons.send, color: Color(0xFFFC995E)),
            onPressed: _sendMessage,  // Send the message when pressed
          ),
        ],
      ),
    );
  }
}
