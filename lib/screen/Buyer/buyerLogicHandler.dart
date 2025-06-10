// lib/utils/buyer_utils.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

/// Fetches seller address & phone from Firestore
Future<Map<String, String>> getSellerContactDetails(String sellerId) async {
  final snap =
      await FirebaseFirestore.instance.collection('users').doc(sellerId).get();

  if (!snap.exists) return {'address': 'No Address', 'phoneNumber': ''};
  final data = snap.data()!;
  return {
    'address': data['address'] ?? 'No Address',
    'phoneNumber': data['phoneNumber'] ?? '',
  };
}

/// Formats an Indian 10‑digit number for WhatsApp URI
String formatPhoneForWhatsapp(String rawPhone) {
  final phone = rawPhone.trim().replaceAll(RegExp(r'\D'), '');
  return (phone.length == 10) ? '91$phone' : phone;
}

/// Launches WhatsApp or shows a SnackBar on failure
Future<void> launchWhatsApp(BuildContext ctx, String rawPhone) async {
  if (rawPhone.isEmpty) {
    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(const SnackBar(content: Text('Phone number not available')));
    return;
  }
  final uri = Uri.parse('https://wa.me/${formatPhoneForWhatsapp(rawPhone)}');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp')));
  }
}

/// Formats number for SMS URI
String formatPhoneForSMS(String rawPhone) {
  var phone = rawPhone.replaceAll(RegExp(r'[^\d]'), '');
  if (!phone.startsWith('91')) phone = '91$phone';
  return phone;
}

/// Launches SMS or shows a SnackBar on failure
Future<void> launchSMS(BuildContext ctx, String rawPhone) async {
  final uri = Uri.parse('sms:${formatPhoneForSMS(rawPhone)}');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(const SnackBar(content: Text('Could not launch SMS')));
  }
}
