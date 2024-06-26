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
        title: Text(T.adminDashboard.tr),
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
                title: Text(T.fullUserList.tr),
              ),
              const SizedBox(
                height: 8,
              ),
              ListTile(
                onTap: () {
                  AdminService.instance.showAdminReportScreen(context: context);
                },
                title: Text(T.reportList.tr),
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
                title: Text(T.sendPushMessageToAllUser.tr),
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
                  print(
                    response.toString(),
                  );
                },
                title: Text(T.mirrorUserDataToFiresotre.tr),
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
                title: Text(T.manageMeetup.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
