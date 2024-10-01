import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class GetQRPage extends StatefulWidget {
  @override
  _GetQRPageState createState() => _GetQRPageState();
}

class _GetQRPageState extends State<GetQRPage> {
  String qrData = "";
  bool isLoading = true; // Loading state
  ScreenshotController screenshotController = ScreenshotController();
  String filePath = ""; // Variable to store the file path

  @override
  void initState() {
    super.initState();
    fetchQRData();
    _requestPermission();
  }

  Future<void> fetchQRData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('qr_codes')
          .doc('your_doc_id')
          .get()
          .timeout(Duration(seconds: 10));

      if (snapshot.exists) {
        setState(() {
          qrData = snapshot.data()?['qr_info'] ?? '';
          isLoading = false;
        });
      } else {
        print("Document does not exist");
        setState(() {
          isLoading = false;
          qrData = "No QR data available";
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
        qrData = "Error fetching QR data";
      });
    }
  }

  Future<void> _downloadQRCode() async {
    try {
      String fileName = 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final directory = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DCIM);

      await Directory('${directory}/SchoolService').create(recursive: true);

      filePath = '${directory}/SchoolService/$fileName'; // Set the file path

      await screenshotController.captureAndSave(
        '${directory}/SchoolService',
        fileName: fileName,
      );

      // Show success dialog with file path
      _showSuccessDialog(filePath);

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

  Future<void> _requestPermission() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }

    await Permission.manageExternalStorage.request();
    await Permission.storage.request();
    await Permission.photos.request();
  }

  // Success popup dialog
  void _showSuccessDialog(String path) {
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
            mainAxisSize: MainAxisSize.min, // To fit content
            children: [
              Text("Your QR code has been saved successfully."),
              SizedBox(height: 10),
              Text(
                "File Path: $path", // Display the file path
                style: TextStyle(color: Colors.black54),
              ),
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
          ? Center(
        child: CircularProgressIndicator(),
      )
          : qrData.isNotEmpty && !qrData.startsWith("Error")
          ? Column(
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
                Text(
                  "Download your QR code",
                  style: TextStyle(fontSize: 16),
                ),
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
                      data: qrData,
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
              padding:
              EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      )
          : Center(
        child: Text(
          "Error: $qrData",
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      ),
    );
  }
}
