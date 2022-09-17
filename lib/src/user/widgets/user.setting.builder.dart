import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Rebuild the widget when the settings are changed.
///
/// The data of the setting docuemnt will be passed over builder function.
/// If the document does not exists, the settings passed to builder will be a null.
class MySettingsBuilder extends StatelessWidget {
  const MySettingsBuilder(
      {super.key, this.id = 'settings', required this.builder});

  final Widget Function(Map<String, dynamic>? settings) builder;
  final String id;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(UserService.instance.uid!)
            .collection('user_settings')
            .doc(id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator.adaptive();
          }
          if (snapshot.hasError) {
            log("MySettingsBuiler($id) error: ${snapshot.error}");
            return Text(snapshot.error.toString());
          }

          Map<String, dynamic>? settings;
          if (snapshot.data != null && snapshot.data?.exists == true) {
            settings = snapshot.data?.data() as Map<String, dynamic>;
          }
          return builder(settings);
        });
  }
}
