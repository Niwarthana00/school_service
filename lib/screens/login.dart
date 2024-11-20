import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_service/screens/driverr/driver_home.dart';
import 'package:school_service/screens/parent/parent_home.dart';
import 'package:school_service/screens/start.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  late String email,password,username,proPic;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance.signOut();
        email=_emailController.text;
        password=_passwordController.text;
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          try {
            username = await _getUserName(userCredential.user!.uid) ?? 'Unknown';
            proPic = await _getUserproPic(userCredential.user!.uid) ?? '';
            String? userType = await _getUserType(userCredential.user!.uid);

            if (userType != null) {
              _navigateBasedOnUserType(userType);
            } else {
              _showErrorModal('Unable to determine user type');
            }
          } catch (e) {
            _showErrorModal('Error retrieving user details');
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          _showErrorModal('Incorrect email or password.');
        } else if (e.code == 'invalid-email') {
          _showErrorModal('Invalid email format.');
        } else {
          _showErrorModal('Incorrect email or password.');
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _googleSignIn() async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential.user != null) {
          String? userType = await _getUserType(userCredential.user!.uid);
          _navigateBasedOnUserType(userType);
        }
      }
    } catch (e) {
      _showErrorModal('Google Sign-In failed. Please try again.');
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

  Future<void> _navigateBasedOnUserType(String? userType) async {
    if (userType == 'Driver') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DriverHome()),
      );
    } else if (userType == 'Parent') {


      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Retrieve existing users
      List<String>? users = prefs.getStringList('users') ?? [];

      bool notExists=true;
      for (var element in users) {
        List<String> parts = element.split('|');
        if(email==parts[1]){
          notExists=false;
        }
      }

      if(notExists){
       users.add(("$username|$email|$proPic|$password"));
      }
      await prefs.setStringList('users', users);


      Navigator.pushReplacement(
        context,

        MaterialPageRoute(builder: (context) => ParentHome()),

      );
    } else {
      _showErrorModal('User type not recognized.');
    }
  }

  void _showErrorModal(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, color: Colors.red, size: 50),
              SizedBox(height: 15),
              Text(
                'Error',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Modal එක close කරයි
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,

                ),
              ),
            )


            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/login.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFC995E).withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Login Now',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                        bottom: Radius.circular(16),
                      ),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 30),
                            _isLoading
                                ? CircularProgressIndicator()
                                : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                  EdgeInsets.symmetric(vertical: 15),
                                  backgroundColor: Color(0xFFFC995E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(0),
                                  ),
                                ),
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    'or use',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _googleSignIn,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                ),
                                icon: Image.asset(
                                  'assets/images/google.png',
                                  width: 20,
                                  height: 20,
                                ),
                                label: Text(
                                  'Login with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don’t have an account? ',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Start()),
                                    );
                                  },
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],


                        ),
                      ),
                    ),
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
