import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverProfileDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: FutureBuilder<DocumentSnapshot>(
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

            var driverData = snapshot.data!.data() as Map<String, dynamic>;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top section with gradient and profile info
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 20, bottom: 30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFC995E), Colors.orange.shade100],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Column(
                      children: [
                        // Close button
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        // Title
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Driver Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        // Profile picture
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: driverData['profileImageUrl'] != null
                              ? NetworkImage(driverData['profileImageUrl'])
                              : AssetImage('assets/images/placeholder.png') as ImageProvider,
                        ),
                      ],
                    ),
                  ),

                  // Details section
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      children: [
                        InfoRow(icon: Icons.person, text: driverData['fullName']),
                        InfoRow(icon: Icons.location_on, text: driverData['address']),
                        InfoRow(icon: Icons.phone, text: driverData['phoneNumber']),
                        InfoRow(icon: Icons.directions_car, text: driverData['vehicleNumber']),
                        InfoRow(icon: Icons.email, text: driverData['email']),
                      ],
                    ),
                  ),

                  // Call and Message buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Already in chat screen, so just close dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFC995E),
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(12),
                          ),
                          child: Icon(Icons.message, color: Colors.white),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final phoneNumber = driverData['phoneNumber'];
                            final Uri launchUri = Uri(
                              scheme: 'tel',
                              path: phoneNumber,
                            );
                            if (await canLaunch(launchUri.toString())) {
                              await launch(launchUri.toString());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFC995E),
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(12),
                          ),
                          child: Icon(Icons.phone, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// InfoRow widget remains the same as in ParentDetails
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  InfoRow({required this.icon, required this.text});

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
        ],
      ),
    );
  }
}