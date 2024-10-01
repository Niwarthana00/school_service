import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase import for logout
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage import
import 'package:school_service/screens/login.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'dart:io'; // For File

class DriverProfile extends StatefulWidget {
  @override
  _DriverProfileState createState() => _DriverProfileState();
}

class _DriverProfileState extends State<DriverProfile> {
  Map<String, dynamic>? driverData;
  File? _profileImage; // Store the selected image
  bool isLoading = false; // To handle loading state while uploading image

  @override
  void initState() {
    super.initState();
    _fetchDriverData();
  }

  Future<void> _fetchDriverData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (driverSnapshot.exists) {
          setState(() {
            driverData = driverSnapshot.data() as Map<String, dynamic>?;
          });
        }
      }
    } catch (e) {
      print("Error fetching driver data: $e");
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path); // Set the selected image
      });

      // Upload the image to Firebase Storage
      await _uploadImageToFirebaseStorage();
    }
  }

  Future<void> _uploadImageToFirebaseStorage() async {
    try {
      setState(() {
        isLoading = true; // Show loading indicator
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && _profileImage != null) {
        // Firebase Storage reference with folder name 'driver/{uid}/profile_pic.jpg'
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('driver/${user.uid}/profile_pic.jpg');

        // Upload the image file to Firebase Storage
        await storageRef.putFile(_profileImage!);

        // Get the download URL of the uploaded image
        final String downloadUrl = await storageRef.getDownloadURL();

        // Save the image URL to Firestore under the user's document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profileImageUrl': downloadUrl});

        // Fetch updated driver data
        _fetchDriverData();

        setState(() {
          isLoading = false; // Hide loading indicator
        });

        _showSuccessDialog('Success', 'Profile picture updated successfully.', true);
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
      _showSuccessDialog('Error', 'Failed to upload profile picture.', false);
      print("Error uploading image: $e");
    }
  }

  void _openEditDialog(String field) {
    final TextEditingController controller = TextEditingController(
      text: driverData?[field]?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new $field'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .update({field: controller.text});

                  _fetchDriverData();
                  Navigator.pop(context);

                  // Show success popup
                  _showSuccessDialog('Success', 'Your data has been updated successfully.', true);
                } catch (e) {
                  Navigator.pop(context);

                  // Show error popup
                  _showSuccessDialog('Error', 'Failed to update your data. Please try again.', false);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                color: isSuccess ? Colors.green : Colors.red,
                size: 60,
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: isSuccess ? Colors.green : Colors.red,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the popup
                },
                child: Text("OK"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? Colors.green : Colors.red, // Button color
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loader when uploading
          : driverData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: CurvedHeaderClipper(),
                  child: Container(
                    height: 310,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/orange.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 50, // Moved slightly higher
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage, // Opens gallery to pick image
                        child: CircleAvatar(
                          radius: 70, // Made larger
                          backgroundColor: Colors.white,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : (driverData?['profileImageUrl'] != null
                              ? NetworkImage(driverData!['profileImageUrl'])
                              : null) as ImageProvider?,
                          child: _profileImage == null && driverData?['profileImageUrl'] == null
                              ? Icon(Icons.camera_alt, size: 70, color: Colors.grey)
                              : null, // Placeholder icon if no image is selected
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        driverData?['fullName'] ?? 'Driver Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 90),
            Container(
              width: double.infinity,
              color: Color(0xFFFADDC4),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              alignment: Alignment.centerLeft,
              child: Text(
                'Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(driverData?['fullName'] ?? 'Full Name'),
              trailing: Icon(Icons.edit, color: Colors.black38),
              onTap: () => _openEditDialog('fullName'),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text(driverData?['address'] ?? 'Address'),
              trailing: Icon(Icons.edit, color: Colors.black38),
              onTap: () => _openEditDialog('address'),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text(driverData?['phoneNumber'] ?? 'Phone Number'),
              trailing: Icon(Icons.edit, color: Colors.black38),
              onTap: () => _openEditDialog('phoneNumber'),
            ),
            ListTile(
              leading: Icon(Icons.directions_car),
              title: Text(driverData?['vehicleNumber'] ?? 'Vehicle Number'),
              trailing: Icon(Icons.edit, color: Colors.black38),
              onTap: () => _openEditDialog('vehicleNumber'),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              color: Color(0xFFFADDC4),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              alignment: Alignment.centerLeft,
              child: Text(
                'Content',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Download'),
                onTap: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () => _logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 80);

    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 80);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: DriverProfile()));
}
