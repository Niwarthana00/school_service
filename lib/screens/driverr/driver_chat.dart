import 'package:flutter/material.dart';

class DriverChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100, // Increase height to accommodate gradient
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFD8C0), Color(0xFFFC995E)], // Gradient colors for the background
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
                colors: [Color(0xFFFFA726), Color(0xFFFC995E)], // Gradient for the search bar background
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFFFE6D9), // Inside color of the search bar
                contentPadding: EdgeInsets.symmetric(vertical: 12), // Reduce height
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
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: 8, // You can dynamically adjust this number
        itemBuilder: (context, index) {
          return Column(
            children: [
              ChatListTile(),
              Divider( // Add a line below each chat item
                thickness: 1,
                color: Colors.grey.shade300,
              ),
            ],
          );
        },
      ),
    );
  }
}

class ChatListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage('assets/images/avatar.png'), // Placeholder for avatar image
      ),
      title: Text(
        'Dumindu Jayasekara',
        style: TextStyle(
          fontWeight: FontWeight.bold, // Make name bold
          fontSize: 14, // Reduce font size
        ),
      ),
      subtitle: Text(
        "Seeking advice on Ola's Sushi - interested in portion size and quality",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '9:30 AM',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(height: 4),
          CircleAvatar(
            radius: 6,
            backgroundColor: Colors.grey.shade300, // Indicator circle
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DriverChat(),
  ));
}
