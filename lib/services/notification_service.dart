import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:firebase_core/firebase_core.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/api.dart' show AsymmetricKeyParameter;
import 'package:pointycastle/signers/rsa_signer.dart';
import 'package:basic_utils/basic_utils.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const String _serviceAccountPath = 'assets/keys/schoolservice-7712d-694c4a2f3587.json';
  Map<String, dynamic>? _serviceAccount;
  String? _cachedAccessToken;
  DateTime? _tokenExpiration;

  Future<void> initializeMessaging() async {
    try {
      final String jsonString = await rootBundle.loadString(_serviceAccountPath);
      _serviceAccount = json.decode(jsonString);

      if (_serviceAccount == null) {
        throw Exception('Failed to load service account file');
      }

      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _localNotificationsPlugin.initialize(initializationSettings);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          _showNotification(
            message.notification!.title ?? 'No Title',
            message.notification!.body ?? 'No Body',
          );
        }
      });

      String? token = await _firebaseMessaging.getToken();
      print("FCM Token: $token");
    } catch (e) {
      print('Error initializing messaging: $e');
      rethrow;
    }
  }

  Future<String> _getAccessToken() async {
    if (_serviceAccount == null) {
      throw Exception('Service account not initialized');
    }

    if (_cachedAccessToken != null &&
        _tokenExpiration != null &&
        DateTime.now().isBefore(_tokenExpiration!)) {
      return _cachedAccessToken!;
    }

    try {
      final url = Uri.parse('https://oauth2.googleapis.com/token');
      final jwt = _generateJWT();

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          'assertion': jwt,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _cachedAccessToken = data['access_token'];
        _tokenExpiration = DateTime.now().add(Duration(seconds: data['expires_in']));
        return _cachedAccessToken!;
      } else {
        throw Exception('Failed to get access token: ${response.body}');
      }
    } catch (e) {
      print('Error getting access token: $e');
      rethrow;
    }
  }

  String _generateJWT() {
    if (_serviceAccount == null) {
      throw Exception('Service account not initialized');
    }

    final header = base64UrlEncode(utf8.encode(json.encode({
      'alg': 'RS256',
      'typ': 'JWT',
    })));

    final now = DateTime.now();
    final claim = base64UrlEncode(utf8.encode(json.encode({
      'iss': _serviceAccount!['client_email'],
      'scope': 'https://www.googleapis.com/auth/firebase.messaging',
      'aud': 'https://oauth2.googleapis.com/token',
      'exp': now.add(Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
    })));

    final signature = _signJWT('$header.$claim', _serviceAccount!['private_key']);
    return '$header.$claim.$signature';
  }

  String _signJWT(String input, String privateKey) {
    try {
      // Parse the PEM private key
      final RSAPrivateKey private = CryptoUtils.rsaPrivateKeyFromPem(privateKey);

      // Create the RSA signer with SHA-256
      final SHA256Digest sha256 = SHA256Digest();
      final RSASigner signer = RSASigner(sha256, '0609608648016503040201');
      signer.init(true, PrivateKeyParameter<RSAPrivateKey>(private));

      // Sign the input
      final signature = signer.generateSignature(utf8.encode(input) as Uint8List);

      // Return base64url encoded signature
      return base64UrlEncode(signature.bytes);
    } catch (e) {
      print('Error signing JWT: $e');
      rethrow;
    }
  }

  Future<void> sendNotification({
    required String targetToken,
    required String title,
    required String body,
  }) async {
    final String jsonString = await rootBundle.loadString(_serviceAccountPath);
    _serviceAccount = json.decode(jsonString);
    if (_serviceAccount == null) {
      throw Exception('Service account not initialized');
    }

    try {
      final accessToken = await _getAccessToken();
      final url = Uri.parse(
          'https://fcm.googleapis.com/v1/${_serviceAccount!['project_id']}/messages:send');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'message': {
            'token': targetToken,
            'notification': {
              'title': title,
              'body': body,
            },
            'android': {
              'priority': 'high',
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.body}');
        throw Exception('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
      rethrow;
    }
  }

  Future<void> _showNotification(String title, String body) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        channelDescription: 'channel_description',
        importance: Importance.high,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );

      await _localNotificationsPlugin.show(
        0,
        title,
        body,
        notificationDetails,
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }
}