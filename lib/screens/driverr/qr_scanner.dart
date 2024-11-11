import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserStatus {
  homeDrop,
  morningPickup,
  schoolDrop,
  schoolPickup
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
  bool isUpdatingStatus = false;  // Flag to track if the status update is in progress
  String? lastScannedCode;  // Variable to store the last scanned QR code

  Future<void> _showSuccessDialog(BuildContext context, String currentStatus, String nextStatus) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
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
              SizedBox(height: 8),
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
            children: [
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

  Future<void> _updateUserStatus(String email, BuildContext context) async {
    if (isUpdatingStatus) return; // Prevent repeated executions
    setState(() {
      isUpdatingStatus = true;  // Set the flag to true when updating status
    });




    // Check if this QR code has already been scanned
    if (email == lastScannedCode) {
      setState(() {
        isUpdatingStatus = false;  // Reset the flag
      });
      return;  // If same QR code, do nothing
    }

    // Update the last scanned QR code
    lastScannedCode = email;

    // Clear the lastScannedCode after 10 seconds
    Future.delayed(Duration(seconds: 10), () {
      setState(() {
        lastScannedCode = null; // Clear the lastScannedCode after 5 seconds
      });
    });

    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

    try {
      final querySnapshot = await usersCollection.where('email', isEqualTo: email).get();

      if (querySnapshot.docs.isNotEmpty) {
        final docData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        final docId = querySnapshot.docs.first.id;

        // Get current status
        String currentStatusStr = docData['status'] ?? UserStatus.homeDrop.toShortString();

        // Convert string to enum
        UserStatus currentStatus = UserStatus.values.firstWhere(
                (e) => e.toShortString() == currentStatusStr,
            orElse: () => UserStatus.homeDrop
        );

        // Get next status
        UserStatus? nextStatus = currentStatus.getNextStatus();

        // Only proceed if there's a valid next status
        if (nextStatus != null) {
          // Update the status without confirmation
          await usersCollection.doc(docId).update({
            'status': nextStatus.toShortString()
          });

          // Show success modal
          if (context.mounted) {
            await _showSuccessDialog(
                context,
                currentStatusStr,
                nextStatus.toShortString()
            );
          }
        } else {
          // Show error modal for invalid status update
          if (context.mounted) {
            await _showErrorDialog(
                context,
                'This status cannot be updated at this time'
            );
          }
        }
      } else {
        // Show error modal for user not found
      }
    } catch (e) {
      if (context.mounted) {
        await _showErrorDialog(context, 'Error: $e');
      }
    } finally {
      setState(() {
        isUpdatingStatus = false;  // Reset the flag once the operation is complete
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        centerTitle: true,
      ),
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
