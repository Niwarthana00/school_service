import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_service/screens/parent/parent_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'driverr/driver_home.dart';
import 'login.dart';

class AccountPickerPage extends StatefulWidget {
  @override
  _AccountPickerPageState createState() => _AccountPickerPageState();
}

class _AccountPickerPageState extends State<AccountPickerPage> {
  List<String> loggedInAccounts = [];

  @override
  void initState() {
    super.initState();
    _loadLoggedAccounts();
  }

  Future<void> _loadLoggedAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedInAccounts = prefs.getStringList('users') ?? [];
    });
  }

  Future<Map<String, dynamic>?> _getUserDetails(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        return userDoc.data();
      }
      return null;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  Future<String?> _getUserType(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        return userDoc.data()?['userType'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching userType: $e');
      return null;
    }
  }  Future<String?> _getUserName(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        return userDoc.data()?['name'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching name: $e');
      return null;
    }
  } Future<String?> _getUserproPic(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        return userDoc.data()?['profilePicUrl'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching name: $e');
      return null;
    }
  }
  void _switchAccount(String email, String password) async {
    try {
      await FirebaseAuth.instance.signOut();

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        String? userType = await _getUserType(userCredential.user!.uid);

        if (userType == 'Parent') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ParentHome()),
          );
        } else if (userType == 'Driver') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DriverHome()),
          );
        } else {
          _showErrorModal('Invalid user type. Unable to log in.');
        }
      }
    } catch (e) {
      _showErrorModal('Account switch failed. Please try again.');
    }
  }


  void _showErrorModal(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
              SizedBox(height: 15),
              Text(
                'Oops!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Understood',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _addNewAccount() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFFC995E),
        title: Text(
          'Switch Accounts',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: loggedInAccounts.length,
              itemBuilder: (context, index) {
                final account = loggedInAccounts[index];
                List<String> parts = account.split('|');

                return FutureBuilder<Map<String, dynamic>?>(
                  future: _getUserDetails(parts[1]),
                  builder: (context, userDetailsSnapshot) {
                    String profilePicUrl = parts[2];
                    String userType = userDetailsSnapshot.data?['userType'] ?? '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Color(0xFFFC995E).withOpacity(0.2),
                            backgroundImage: profilePicUrl.isNotEmpty
                                ? NetworkImage(profilePicUrl)
                                : null,
                            child: profilePicUrl.isEmpty
                                ? Text(
                              parts[2],
                              style: TextStyle(
                                  color: Color(0xFFFC995E),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold
                              ),
                            )
                                : null,
                          ),
                          title: Text(
                            parts[0],
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                fontSize: 16
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                parts[1],
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                userType,
                                style: TextStyle(
                                    color: Color(0xFFFC995E),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Color(0xFFFC995E),
                            size: 20,
                          ),
                          onTap: () => _switchAccount(parts[1], parts[3]),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(color: Colors.grey[300], height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFFFC995E),
                  size: 28,
                ),
                title: Text(
                  'Add Another Account',
                  style: TextStyle(
                      color: Color(0xFFFC995E),
                      fontWeight: FontWeight.w600,
                      fontSize: 16
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFFC995E),
                  size: 20,
                ),
                onTap: _addNewAccount,
              ),
            ),
          ),
        ],
      ),
    );
  }
}