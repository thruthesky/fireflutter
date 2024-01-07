import 'package:fireship/fireship.dart';
import 'package:fireship/fireship.test.functions.dart';
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
      body: Column(
        children: [
          const Text('Chat'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () {
                  AdminService.instance.showUserList(context: context);
                },
                child: const Text('전체 사용자 목록'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('신고목록'),
              )
            ],
          ),
        ],
      ),
    );
  }
}
