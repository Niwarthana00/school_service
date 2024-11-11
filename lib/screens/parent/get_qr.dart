import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class GetQRPage extends StatefulWidget {
  @override
  _GetQRPageState createState() => _GetQRPageState();
}

class _GetQRPageState extends State<GetQRPage> {
  String qrData = ""; // To hold user's email for QR generation
  bool isLoading = false; // Loading state
  ScreenshotController screenshotController = ScreenshotController();
  String filePath = ""; // To store saved file path

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _fetchUserEmail(); // Fetch email upon initialization
  }

  // Fetch the user's email from Firebase Auth and set it to qrData
  Future<void> _fetchUserEmail() async {
    setState(() {
      isLoading = true; // Start loading
    });
    try {
      User? user = FirebaseAuth.instance.currentUser; // Get the current user
      if (user != null) {
        qrData = user.email ?? ""; // Set user's email to qrData
      }
    } catch (e) {
      print("Error fetching user email: $e");
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  // Request necessary permissions
  Future<void> _requestPermission() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    await Permission.manageExternalStorage.request();
    await Permission.photos.request();
  }

  // Method to download the QR code as an image
  Future<void> _downloadQRCode() async {
    try {
      String fileName = 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final directory = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DCIM);

      await Directory('${directory}/SchoolService').create(recursive: true);
      filePath = '${directory}/SchoolService/$fileName';

      await screenshotController.captureAndSave(
        '${directory}/SchoolService',
        fileName: fileName,
      );

      _showSuccessDialog(filePath, qrData);

    } catch (e) {
      print("Error downloading QR code: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save QR code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show success dialog with file path and email
  void _showSuccessDialog(String path, String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 50),
              Text('SUCCESS!', style: TextStyle(color: Colors.green)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Your QR code has been saved successfully."),
              SizedBox(height: 10),
              Text("File Path: $path", style: TextStyle(color: Colors.black54)),
              SizedBox(height: 10),
              Text("Email: $email", style: TextStyle(color: Colors.black54)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download QR code'),
        backgroundColor: Color(0xFFFC995E),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading if fetching email
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5.0,
                ),
              ],
            ),
            child: Column(
              children: [
                Text("Download your QR code", style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Divider(
                  thickness: 1,
                  color: Colors.black12,
                  indent: 40,
                  endIndent: 40,
                ),
                Screenshot(
                  controller: screenshotController,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: QrImageView(
                      data: qrData, // QR code containing user's email
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            icon: Icon(Icons.download),
            label: Text('Download QR'),
            onPressed: _downloadQRCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFC995E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
