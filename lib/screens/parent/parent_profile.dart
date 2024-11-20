import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:school_service/screens/AccountPickerPage.dart';
import 'package:school_service/screens/login.dart';

class ParentProfile extends StatefulWidget {
  @override
  _ParentProfileState createState() => _ParentProfileState();
}

class _ParentProfileState extends State<ParentProfile> {
  File? _image;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  String name = '';
  String address = '';
  String phoneNumber = '';
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        name = userData['name'];
        address = userData['address'];
        phoneNumber = userData['phoneNumber'];
        imageUrl = userData['profilePicUrl'];
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadImageToStorage();
    }
  }

  Future<void> _uploadImageToStorage() async {
    if (_image == null) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Reference storageRef = _storage.ref().child('${user.uid}/parent/profile_pic.jpg');
        await storageRef.putFile(_image!);
        String downloadUrl = await storageRef.getDownloadURL();
        await _firestore.collection('users').doc(user.uid).update({'profilePicUrl': downloadUrl});
        setState(() {
          imageUrl = downloadUrl;
        });
        _showSuccessDialog('Profile picture updated successfully!');

      }
    } catch (e) {
      _showErrorMessage('Failed to upload image. Please try again.');
    }
  }

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

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter new $field',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _updateUserData(field, controller.text);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

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
        });
        _showSuccessDialog('Updated successfully!');
      } catch (error) {
        _showErrorMessage('Failed to update. Please try again.');
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 70,
                ),
                SizedBox(height: 20),
                Text(
                  message,
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => AccountPickerPage()),
                      (route) => false,
                );
              },
              child: Text(
                'Logout',
                style: TextStyle(color: Color(0xFFFC995E)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _switchToAnotherAccount(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
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
                    onTap: _pickImage,
                    child: ClipOval(
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: imageUrl == null
                            ? Icon(Icons.person, size: 50)
                            : Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
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
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 30),
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFC995E),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),


            GestureDetector(
              onTap: () => _switchToAnotherAccount(context),
              child: Container(
                padding: EdgeInsets.all(12),
                width: 100,
                color: Colors.grey[200],
                child: Center(
                  child: Text(
                    'Switch to Another Account',
                    style: TextStyle(fontSize: 16, color: Color(0xFFFC995E)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
            Icon(Icons.edit, size: 24),
          ],
        ),
      ),
    );
  }
}

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