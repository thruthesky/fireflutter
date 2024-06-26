import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminDashBoardScreen extends StatefulWidget {
  const AdminDashBoardScreen({super.key});

  @override
  State<AdminDashBoardScreen> createState() => _AdminDashBoardScreenState();
}

class _AdminDashBoardScreenState extends State<AdminDashBoardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin DashBoard'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // const Text('Chat'),
              ListTile(
                onTap: () {
                  AdminService.instance.showUserList(context: context);
                },
                title: const Text('전체 사용자 목록'),
              ),
              const SizedBox(
                height: 8,
              ),
              ListTile(
                onTap: () {}, // AdminService.instance.showReport(),
                title: const Text('신고목록'),
              ),
              const SizedBox(
                height: 8,
              ),
              ListTile(
                onTap: () async {
                  final re = await confirm(
                    context: context,
                    title: 'Send Push notification',
                    message: 'Are you sure you want to send push notification?',
                  );
                  if (re == false) return;
                  MessagingService.instance.sendAll(
                    title: 'send all test - ${DateTime.now()}',
                    body: 'this is the content of the message',
                  );
                },
                title: const Text('Send push messages to all users'),
              ),
              const SizedBox(
                height: 8,
              ),
              ListTile(
                onTap: () async {
                  final re = await confirm(
                    context: context,
                    title: 'Send Push notification',
                    message: 'Are you sure you want to send push notification?',
                  );
                  if (re == false) return;
                  final result = await AdminService.instance
                      .mirrorUserBackfillRtdbToFirestore();
                  final response = result.data;
                  print(response.toString());
                },
                title: const Text('Mirror User Data To Firestore'),
              ),
              const SizedBox(
                height: 8,
              ),
              ListTile(
                onTap: () async {
                  showGeneralDialog(
                      context: context,
                      pageBuilder: (_, __, ___) =>
                          const AdminMeetupListScreen());
                },
                title: const Text('Meetup Management'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
