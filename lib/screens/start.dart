import 'package:flutter/material.dart';
import 'signup_screen.dart'; // Import the SignupScreen

class Start extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: 393,
            height: 852,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                // Background image and overlay
                Positioned(
                  left: -2,
                  top: 0,
                  child: Container(
                    width: 395,
                    height: 852,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 2,
                          top: 0,
                          child: Container(
                            width: 393,
                            height: 410,
                            decoration: ShapeDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/bus.png'), // Use AssetImage
                                fit: BoxFit.fill,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 393,
                            height: 296,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 2,
                          top: 278,
                          child: Container(
                            width: 393,
                            height: 574,
                            decoration: ShapeDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(0.00, -1.00),
                                end: Alignment(0, 1),
                                colors: [
                                  Color(0xFFFEC4A1),
                                  Color(0xFFFFD7BF),
                                  Color(0xE5FFFDFD)
                                ],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // SafeRide Logo
                Positioned(
                  left: 66,
                  top: 364,
                  child: Container(
                    width: 256,
                    height: 116,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/saferide.png'), // Use AssetImage
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                // Text 'Choose your role to proceed'
                Positioned(
                  left: 71,
                  top: 480,
                  child: SizedBox(
                    width: 250,
                    height: 18,
                    child: Text(
                      'Choose your role to proceed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                // Driver Button
                Positioned(
                  left: 42,
                  top: 599,
                  child: Container(
                    width: 139,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(0xFFFC995E),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x3D000000),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignupScreen(userType: 'Driver'), // Pass Driver
                          ),
                        );
                      },
                      child: Text(
                        'DRIVER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                // Parent Button
                Positioned(
                  left: 212,
                  top: 599,
                  child: Container(
                    width: 139,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(0xFFFC995E),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x3D000000),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignupScreen(userType: 'Parent'), // Pass Parent
                          ),
                        );
                      },
                      child: Text(
                        'PARENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                // Footer text 'Designed and Developed with Love ❤️'
                Positioned(
                  left: 96,
                  top: 816,
                  child: SizedBox(
                    width: 201,
                    height: 16,
                    child: Text(
                      'Designed and Developed with Love ❤️',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xB2484444),
                        fontSize: 5,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}