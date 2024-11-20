import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  Future<void> saveParentToken(String email) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('statuses').doc(email).set(
          {'deviceToken': token},
          SetOptions(merge: true), // Merge to avoid overwriting other fields
        );
        print('Parent device token saved successfully.');
      } else {
        print('Failed to generate device token.');
      }
    } catch (e) {
      print('Error saving parent device token: $e');
    }
  }
}
