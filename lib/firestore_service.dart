import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future<void> saveUserData(
      String userType,
      String fullName,
      String email,
      String password,
      ) async {
    try {
      await usersCollection.add({
        'userType': userType,
        'fullName': fullName,
        'email': email,
        'password': password,
        // Add any other fields you need
      });
    } catch (e) {
      print('Error saving user data: $e');
      // Handle errors as needed
    }
  }
}
