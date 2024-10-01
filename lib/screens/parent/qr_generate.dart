import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage import
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:school_service/screens/parent/get_qr.dart';

class StudentDetailsPage extends StatefulWidget {
  @override
  _StudentDetailsPageState createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  File? _image;
  String fullName = '';
  String grade = '';
  String address = '';
  String phoneNumber = '';
  String uid = ''; // For storing the logged-in user's UID
  String? profilePicUrl; // To store the profile picture URL

  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Firebase Storage instance

  // Method to pick image
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Upload the image to Firebase Storage
      await _uploadImageToStorage();
    }
  }

  // Method to upload image to Firebase Storage
  Future<void> _uploadImageToStorage() async {
    if (_image == null) return; // Exit if no image is selected

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        uid = currentUser.uid;
        // Create a reference to Firebase Storage for the student's profile picture
        Reference storageRef = _storage.ref().child('$uid/student/profile_pic.jpg');

        // Upload the file
        await storageRef.putFile(_image!);

        // Get the download URL
        String downloadUrl = await storageRef.getDownloadURL();

        // Update Firestore with the new profile picture URL
        await _firestore.collection('users').doc(uid).update({'studentProfilePicUrl': downloadUrl});

        setState(() {
          profilePicUrl = downloadUrl; // Update the state with the new URL
        });

        _showSuccessMessage('Profile picture updated successfully!');
      }
    } catch (e) {
      _showErrorMessage('Failed to upload image. Please try again.');
    }
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      uid = currentUser.uid;
      // Fetch user data from Firestore based on UID
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          fullName = userDoc['fullName'];
          grade = userDoc['grade'];
          address = userDoc['address'];
          phoneNumber = userDoc['phoneNumber'];
          profilePicUrl = userDoc['studentProfilePicUrl']; // Fetch the profile picture URL
        });
      } else {
        print("User document not found!");
      }
    }
  }

  // Method to update Firestore when the user edits a detail
  Future<void> _updateUserData(String field, String newValue) async {
    if (uid.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update({field: newValue});
      // Fetch updated data to display on screen
      _fetchUserData();
      _showSuccessMessage('Data updated successfully!');
    }
  }

  // Method to show success message after saving data
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
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Method to show error message
  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Icon(Icons.error, color: Colors.red, size: 50),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Method to show edit dialog
  void _editDetail(String fieldName, String currentValue) {
    TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $fieldName'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new $fieldName'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  // Update Firestore with new value
                  _updateUserData(fieldName, controller.text);
                  Navigator.of(context).pop(); // Close the dialog after saving
                } else {
                  _showErrorMessage('Please enter a valid $fieldName.');
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (profilePicUrl != null ? NetworkImage(profilePicUrl!) : null),
                  child: _image == null && profilePicUrl == null
                      ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                      : null,
                ),
              ),
              SizedBox(height: 16),
              // Student Name (fullName)
              Text(
                fullName.isEmpty ? 'Loading...' : fullName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Divider(),
              // Details Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Details',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFC995E)),
                ),
              ),
              SizedBox(height: 16),
              _buildDetailRow(Icons.person, 'fullName', fullName),
              _buildDetailRow(Icons.school, 'grade', grade),
              _buildDetailRow(Icons.home, 'address', address),
              _buildDetailRow(Icons.phone, 'phoneNumber', phoneNumber),
              SizedBox(height: 30),
              // Generate QR Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GetQRPage()),
                  );
                },
                child: Text(
                  'Generate QR',
                  style: TextStyle(fontSize: 18, color: Color(0xFFFFFFFF)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFC995E),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  side: BorderSide(color: Color(0xFFFC995E)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build each detail row with icon and text
  Widget _buildDetailRow(IconData icon, String fieldName, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[700]),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              detail.isEmpty ? 'Loading...' : detail,
              style: TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, size: 20, color: Colors.grey[500]),
            onPressed: () {
              _editDetail(fieldName, detail);
            },
          ),
        ],
      ),
    );
  }
}
