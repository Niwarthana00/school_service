import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ParentDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .where('userType', isEqualTo: 'Driver')
            .limit(1)
            .get()
            .then((snapshot) => snapshot.docs.first),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No driver found'));
          }

          // Driver data
          var driverData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Top section with gradient and profile info
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 60, bottom: 70),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFC995E), Colors.orange.shade100],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Displaying the profile picture
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: driverData['profilePicture'] != null
                            ? NetworkImage(driverData['profilePicture']) // Use the URL from Firestore
                            : AssetImage('assets/images/placeholder.png'), // Use a placeholder if no image
                      ),
                      SizedBox(height: 10),
                      Text(
                        driverData['fullName'] ?? 'No name provided',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 50),

                // Details section highlighted
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: Color(0xFFFADDC4),
                  width: double.infinity,
                  child: Text(
                    'Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),

                // Information list
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoRow(icon: Icons.person, text: driverData['fullName']),
                      InfoRow(icon: Icons.location_on, text: driverData['address']),
                      InfoRow(icon: Icons.phone, text: driverData['phoneNumber']),
                      InfoRow(icon: Icons.directions_car, text: driverData['vehicleNumber']),
                      InfoRow(icon: Icons.email, text: driverData['email']),
                    ],
                  ),
                ),

                // Buttons for call and message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Message Button
                      ElevatedButton(
                        onPressed: () {
                          // Implement message feature
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFC995E),
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(16),
                        ),
                        child: Icon(Icons.message, color: Colors.white),
                      ),
                      // Call Button
                      ElevatedButton(
                        onPressed: () async {
                          final phoneNumber = driverData['phoneNumber'];
                          final Uri launchUri = Uri(
                            scheme: 'tel',
                            path: phoneNumber,
                          );
                          if (await canLaunch(launchUri.toString())) {
                            await launch(launchUri.toString());
                          } else {
                            throw 'Could not launch $launchUri';
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFC995E),
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(16),
                        ),
                        child: Icon(Icons.phone, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final IconData? suffixIcon;

  InfoRow({required this.icon, required this.text, this.suffixIcon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          if (suffixIcon != null)
            Icon(
              suffixIcon,
              color: Colors.black54,
            ),
        ],
      ),
    );
  }
}
