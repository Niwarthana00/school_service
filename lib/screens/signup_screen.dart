import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_service/providers/auth_provider.dart';
import 'package:school_service/screens/driverr/add_details.dart';
import 'package:school_service/screens/parent/add_details_parent.dart';
import 'login.dart';

class SignupScreen extends StatefulWidget {
  final String? userType;

  SignupScreen({this.userType});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _fullName = '';
  String _errorMessage = ''; // For modal error messages

  // Email validation function
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password validation function
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  // Full name validation function
  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    return null;
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
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background image with gradient overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/singup.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: double.infinity,
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
              ],
            ),
          ),

          // Title
          Positioned(
            top: MediaQuery.of(context).size.height * 0.08,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Create Account as ${widget.userType}',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Card with input fields
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0), // No border radius
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 40),
                        // Full Name TextField
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.zero, // No border radius
                            ),
                          ),
                          onChanged: (value) => _fullName = value,
                          validator: _validateFullName,
                        ),
                        SizedBox(height: 20),
                        // Email TextField
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.zero, // No border radius
                            ),
                          ),
                          onChanged: (value) => _email = value,
                          validator: _validateEmail,
                        ),
                        SizedBox(height: 20),
                        // Password TextField
                        TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.zero, // No border radius
                            ),
                          ),
                          onChanged: (value) => _password = value,
                          validator: _validatePassword,
                        ),
                        SizedBox(height: 40),
                        // Continue Button
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                // Sign up and save initial user data
                                await authProvider.signUp(
                                  _email,
                                  _password,
                                  widget.userType ?? '',
                                  {'name': _fullName},
                                );

                                // Navigate to the appropriate details screen
                                if (widget.userType == 'Driver') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DriverDetailsForm(
                                        userType: widget.userType ?? '',
                                      ),
                                    ),
                                  );
                                } else if (widget.userType == 'Parent') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ParentDetailsForm(
                                        userType: widget.userType ?? '',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                // Show error modal for Firebase exceptions
                                _showErrorModal(
                                  e.toString().contains('email-already-in-use')
                                      ? 'This email is already registered. Please use another email.'
                                      : 'An error occurred. Please try again.',
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFC995E),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero, // No border radius
                            ),
                          ),
                          child: Text(
                            'CONTINUE',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Separator
                        Row(
                          children: <Widget>[
                            Expanded(child: Divider(thickness: 1)),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                'or use',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            Expanded(child: Divider(thickness: 1)),
                          ],
                        ),
                        SizedBox(height: 20),
                        // Add Google Sign-In Button here
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Implement Google Sign-In functionality here
                            },
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

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Login',
                                style: TextStyle(color: Color(0xFFFC995E)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
