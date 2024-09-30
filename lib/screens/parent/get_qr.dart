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
      // Request permission to access external storage (needed for Android)
      // await Permission.storage.status.isGranted
      if (true) {
        // Get the directory where the image will be saved (Pictures directory)
        // final directory = await getDownloadsDirectory();

        final directory = await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DCIM);

        // Define the path where the QR code will be saved
        // final filePath = '${directory!.path}/Pictures/qr_code.png';

        // print(filePath);

        // Create the directory if it doesn't exist
        await Directory('${directory}/Pictures').create(recursive: true);

        // Capture and save the QR code image
        screenshotController
            .captureAndSave(
          '${directory}/Pictures',
          fileName: 'qr_code.png',
        )
            .then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('QR code saved at $directory')),
          );
        });
      } else if (await Permission.storage.isPermanentlyDenied) {
        // If the permission is permanently denied, open the app settings
        await openAppSettings();
      } else {
        // If permission is denied
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission denied')),
        );
        await _requestPermission();
      }
    } catch (e) {
      print("Error downloading QR code: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save QR code')),
      );
    }
  }

  Future<void> _requestPermission() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request(); // Request permission if denied
    }
    print(" Moda Dumindu");

    Permission storageAccessPermission = Permission.manageExternalStorage;
    PermissionStatus externalStoragePermissionStatus =
        await storageAccessPermission.request();

    Permission storagePermission = Permission.storage;
    PermissionStatus storagePermissionStatus =
        await storagePermission.request();

    await storagePermission.request();

    Permission photosPermission = Permission.photos;

    PermissionStatus photoStatus = await photosPermission.request();

    print("permissions are requested");
    print(photoStatus);
    print(externalStoragePermissionStatus);
    print(storagePermissionStatus);

    // await Permission.storage.request();
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
                  child: Text("Error: $qrData"),
                ),
    );
  }
}
