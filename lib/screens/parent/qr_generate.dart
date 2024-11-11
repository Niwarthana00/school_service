import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  String uid = '';
  String? profilePicUrl;
  String? emailqr;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _fetchAndSaveUserData();
  }

  Future<void> _fetchAndSaveUserData() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        uid = currentUser.uid;
        emailqr = currentUser.email;

        DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

          setState(() {
            fullName = userData['fullName']?.toString() ?? '';
            grade = userData['grade']?.toString() ?? '';
            address = userData['address']?.toString() ?? '';
            phoneNumber = userData['phoneNumber']?.toString() ?? '';
            profilePicUrl = userData['studentProfilePicUrl']?.toString();

            // Debug prints
            print('Data fetched successfully');
            print('Full Name: $fullName');
            print('Grade: $grade');
            print('Address: $address');
            print('Phone: $phoneNumber');
            print('Profile URL: $profilePicUrl');
          });
        } else {
          print('No document exists for uid: $uid');
          await _firestore.collection('users').doc(uid).set({
            'emailqr': emailqr,
            'fullName': '',
            'grade': '',
            'address': '',
            'phoneNumber': '',
            'studentProfilePicUrl': '',
          });
        }
      } else {
        print('No user is currently logged in');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      _showErrorMessage('Failed to load user data. Please try again.');
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await _uploadImageToStorage();
      }
    } catch (e) {
      print('Error picking image: $e');
      _showErrorMessage('Failed to pick image. Please try again.');
    }
  }

  Future<void> _uploadImageToStorage() async {
    if (_image == null) return;

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        uid = currentUser.uid;
        Reference storageRef = _storage.ref().child('$uid/student/profile_pic.jpg');

        // Upload the file with metadata
        UploadTask uploadTask = storageRef.putFile(
          _image!,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        // Wait for the upload to complete
        await uploadTask;

        // Get the download URL
        String downloadUrl = await storageRef.getDownloadURL();

        // Update Firestore with the new URL
        await _firestore.collection('users').doc(uid).update({
          'studentProfilePicUrl': downloadUrl
        });

        setState(() {
          profilePicUrl = downloadUrl;
        });

        _showSuccessMessage('Profile picture updated successfully!');
      }
    } catch (e) {
      print('Error uploading image: $e');
      _showErrorMessage('Failed to upload image. Please try again.');
    }
  }

  Future<void> _updateUserData(String field, String newValue) async {
    try {
      if (uid.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update({field: newValue});
        await _fetchAndSaveUserData(); // Refresh the data
        _showSuccessMessage('Data updated successfully!');
      }
    } catch (e) {
      print('Error updating user data: $e');
      _showErrorMessage('Failed to update data. Please try again.');
    }
  }

  void _showSuccessMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Icon(Icons.check_circle, color: Colors.green, size: 50),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Icon(Icons.error, color: Colors.red, size: 50),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _editDetail(String fieldName, String currentValue) {
    TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $fieldName'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter new $fieldName'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _updateUserData(fieldName, controller.text);
                Navigator.of(context).pop();
              } else {
                _showErrorMessage('Please enter a valid $fieldName.');
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String fieldName, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[700]),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              detail.isEmpty ? 'Not set' : detail,
              style: TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, size: 20, color: Colors.grey[500]),
            onPressed: () => _editDetail(fieldName, detail),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (profilePicUrl != null && profilePicUrl!.isNotEmpty
                      ? NetworkImage(profilePicUrl!) as ImageProvider
                      : null),
                  child: (_image == null && (profilePicUrl == null || profilePicUrl!.isEmpty))
                      ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                      : null,
                ),
              ),
              SizedBox(height: 16),
              Text(
                fullName.isEmpty ? 'Add Student Name' : fullName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Divider(),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFC995E),
                  ),
                ),
              ),
              SizedBox(height: 16),
              _buildDetailRow(Icons.person, 'fullName', fullName),
              _buildDetailRow(Icons.school, 'grade', grade),
              _buildDetailRow(Icons.home, 'address', address),
              _buildDetailRow(Icons.phone, 'phoneNumber', phoneNumber),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GetQRPage()),
                  );
                },
                child: Text(
                  'Generate QR',
                  style: TextStyle(fontSize: 18, color: Colors.white),
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
}