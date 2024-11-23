import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_service/services/notification_service.dart';

enum UserStatus {
  homeDrop,
  morningPickup,
  schoolDrop,
  schoolPickup,
}

extension UserStatusExtension on UserStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  UserStatus? getNextStatus() {
    switch (this) {
      case UserStatus.homeDrop:
        return UserStatus.morningPickup;
      case UserStatus.schoolDrop:
        return UserStatus.schoolPickup;
      case UserStatus.schoolPickup:
        return UserStatus.homeDrop;
      default:
        return null;
    }
  }
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isUpdatingStatus = false;
  String? lastScannedCode;

  Future<void> _updateUserStatus(String email, BuildContext context) async {
    if (isUpdatingStatus) return;

    setState(() {
      isUpdatingStatus = true;
    });

    if (email == lastScannedCode) {
      setState(() {
        isUpdatingStatus = false;
      });
      return;
    }

    lastScannedCode = email;

    Future.delayed(const Duration(seconds: 10), () {
      setState(() {
        lastScannedCode = null;
      });
    });

    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    try {
      final querySnapshot =
          await usersCollection.where('email', isEqualTo: email).get();

      if (querySnapshot.docs.isNotEmpty) {
        final docData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        final docId = querySnapshot.docs.first.id;

        String currentStatusStr =
            docData['status'] ?? UserStatus.homeDrop.toShortString();
        String? fcmToken = docData['fcm_token'];

        UserStatus currentStatus = UserStatus.values.firstWhere(
          (e) => e.toShortString() == currentStatusStr,
          orElse: () => UserStatus.homeDrop,
        );

        UserStatus? nextStatus = currentStatus.getNextStatus();

        if (nextStatus != null) {
          await usersCollection.doc(docId).update({
            'status': nextStatus.toShortString(),
          });

          if (fcmToken != null && fcmToken.isNotEmpty) {
            final notificationService = NotificationService();
            try {
              await notificationService.sendNotification(
                targetToken: fcmToken, // Use the actual FCM token from the user
                title: 'Status Updated',
                body: 'Your status has been updated to ${nextStatus.toShortString()}',
              );
            } catch (e) {
              print('Error sending notification: $e');
            }
          }

          if (context.mounted) {
            await _showSuccessDialog(
              context,
              currentStatusStr,
              nextStatus.toShortString(),
            );
          }
        } else {
          if (context.mounted) {
            await _showErrorDialog(
              context,
              'This status cannot be updated at this time.',
            );
          }
        }
      } else {
        if (context.mounted) {
          await _showErrorDialog(context, 'User not found.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        await _showErrorDialog(context, 'Error: $e');
      }
    } finally {
      setState(() {
        isUpdatingStatus = false;
      });
    }
  }

  Future<void> _showSuccessDialog(
      BuildContext context, String currentStatus, String nextStatus) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Status Updated'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Previous Status: $currentStatus'),
              const SizedBox(height: 8),
              Text('New Status: $nextStatus'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(BuildContext context, String message) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Scan QR Code',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      final String? code = barcode.rawValue;
                      if (code != null) {
                        _updateUserStatus(code, context);
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
