import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication for logout
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for user data
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage for images
import 'package:school_service/screens/login.dart'; // Required for login screen navigation

class ParentProfile extends StatefulWidget {
  @override
  _ParentProfileState createState() => _ParentProfileState();
}

class _ParentProfileState extends State<ParentProfile> {
  File? _image; // Variable to store selected image
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Firebase Storage instance
  final ImagePicker _picker = ImagePicker(); // Image picker instance
  String name = '';
  String address = '';
  String phoneNumber = '';
  String? imageUrl; // Variable to store the URL of the uploaded image

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        name = userData['name'];
        address = userData['address'];
        phoneNumber = userData['phoneNumber'];
        imageUrl = userData['profilePicUrl']; // Fetch profile picture URL
      });
    }
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadImageToStorage(); // Upload image after picking
    }
  }

  // Upload image to Firebase Storage
  Future<void> _uploadImageToStorage() async {
    if (_image == null) return; // Exit if no image is selected

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Create a reference for the user's UID folder
        Reference storageRef = _storage.ref().child('${user.uid}/parent/profile_pic.jpg');

        // Upload the image file
        await storageRef.putFile(_image!);

        // Get the download URL
        String downloadUrl = await storageRef.getDownloadURL();

        // Update Firestore with the new profile picture URL
        await _firestore.collection('users').doc(user.uid).update({'profilePicUrl': downloadUrl});

        // Update local state
        setState(() {
          imageUrl = downloadUrl;
        });

        _showSuccessMessage('Profile picture updated successfully!');
      }
    } catch (e) {
      _showErrorMessage('Failed to upload image. Please try again.');
    }
  }

  // Logout function with confirmation dialog
  Future<void> _logout(BuildContext context) async {
    bool shouldLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout Confirmation'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout) {
      await FirebaseAuth.instance.signOut(); // Log out from Firebase
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  // Function to show edit dialog
  Future<void> _showEditDialog(String field) async {
    TextEditingController controller = TextEditingController();
    String currentValue = '';

    if (field == 'name') {
      currentValue = name;
    } else if (field == 'address') {
      currentValue = address;
    } else if (field == 'phoneNumber') {
      currentValue = phoneNumber;
    }

    controller.text = currentValue;

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
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _updateUserData(field, controller.text);
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to update user data in Firestore with success/error message
  Future<void> _updateUserData(String field, String value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({field: value});
        setState(() {
          if (field == 'name') {
            name = value;
          } else if (field == 'address') {
            address = value;
          } else if (field == 'phoneNumber') {
            phoneNumber = value;
          }
          _showSuccessMessage('Data updated successfully!');
        });
        _showSuccessMessage('Data updated successfully!');

      } catch (error) {
        // Display error SnackBar
        _showErrorMessage('Failed to update data. Please try again.');
      }
    }
  }

  // Function to show success message in AlertDialog
  void _showSuccessMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Icon(Icons.check_circle, color: Colors.green, size: 50),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Function to show error message in SnackBar
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Parent Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Curved Image Header
            Stack(
              children: [
                Container(
                  height: 250,
                  child: ClipPath(
                    clipper: CurveClipper(),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/orange.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 140,
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child: GestureDetector(
                    onTap: _pickImage, // Select image from gallery
                    child: ClipOval(
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: imageUrl == null
                            ? Icon(Icons.person, size: 50) // Default icon
                            : ClipOval(
                          child: Image.network(
                            imageUrl!, // Display the uploaded image
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Name Display
            Text(
              name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            // Details Section Header
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFFADDC4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailRow(icon: Icons.person, text: name, onEdit: () => _showEditDialog('name')),
                  DetailRow(icon: Icons.location_on, text: address, onEdit: () => _showEditDialog('address')),
                  DetailRow(icon: Icons.phone, text: phoneNumber, onEdit: () => _showEditDialog('phoneNumber')),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Logout Button
            ElevatedButton(
              onPressed: () => _logout(context),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget to display a single detail row with edit capability
class DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onEdit;

  const DetailRow({Key? key, required this.icon, required this.text, required this.onEdit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Icon(icon, size: 24),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 16),
              ),
            ),
            Icon(Icons.edit, size: 24), // Edit icon
          ],
        ),
      ),
    );
  }
}

// Custom clipper for curved header
class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 100);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
