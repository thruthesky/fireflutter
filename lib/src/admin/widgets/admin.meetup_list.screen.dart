import 'package:flutter/material.dart';

class AdminMeetupListScreen extends StatefulWidget {
  static const String routeName = '/AdminMeetupList';
  const AdminMeetupListScreen({super.key});

  @override
  State<AdminMeetupListScreen> createState() => _AdminMeetupListScreenState();
}

class _AdminMeetupListScreenState extends State<AdminMeetupListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdminMeetupList'),
      ),
      body: const Column(
        children: [
          Text("AdminMeetupList"),
        ],
      ),
    );
  }
}
