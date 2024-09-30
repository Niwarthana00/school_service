import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  String? get userId => user?.uid;
  User? _user;
  User? get user => _user;

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _auth?.authStateChanges().listen(_authStateChanged);
  }

  Future<void> signUp(String email, String password, String userType,
      Map<String, dynamic> signUpData) async {
    try {
      UserCredential? result = await _auth?.createUserWithEmailAndPassword(
          email: email, password: password);
      _user = result?.user;

      await _firestore?.collection('users').doc(_user!.uid).set({
        'email': email,
        'userType': userType,
        ...signUpData, // Spread sign-up form data into Firestore document
      });

      notifyListeners(); // Notify listeners of state changes
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  // Function to add driver details after signup
  Future<void> addDriverDetails(Map<String, dynamic> driverDetails) async {
    if (_user == null) throw Exception('No user signed in');

    try {
      await _firestore?.collection('users')
          .doc(_user!.uid)
          .update(driverDetails);
    } catch (e) {
      throw Exception('Failed to update driver details: ${e.toString()}');
    }
  }

  // Function to add parent details after signup
  Future<void> addParentDetails(Map<String, dynamic> parentDetails) async {
    if (_user == null) throw Exception('No user signed in');

    try {
      await _firestore?.collection('users')
          .doc(_user!.uid)
          .update(parentDetails);
    } catch (e) {
      throw Exception('Failed to update parent details: ${e.toString()}');
    }
  }

  // Sign-in function
  Future<void> signIn(String email, String password) async {
    try {
      UserCredential? result = await _auth?.signInWithEmailAndPassword(
          email: email, password: password);
      _user = result?.user;

      notifyListeners(); // Notify listeners of state changes
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Sign out function
  Future<void> signOut() async {
    try {
      await _auth?.signOut();
      _user = null;

      notifyListeners(); // Notify listeners of state changes
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Function to handle auth state changes
  void _authStateChanged(User? firebaseUser) {
    _user = firebaseUser;
    notifyListeners();
  }
}