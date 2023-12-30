import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class DefaultProfileScreen extends StatefulWidget {
  const DefaultProfileScreen({super.key});

  @override
  State<DefaultProfileScreen> createState() => _DefaultProfileScreenState();
}

class _DefaultProfileScreenState extends State<DefaultProfileScreen> {
  final nameController = TextEditingController();
  UserModel get user => UserService.instance.user!;

  @override
  void initState() {
    super.initState();
    nameController.text = user.displayName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    DefaultAvatarUpdate(
                      uid: UserService.instance.user!.uid,
                      radius: 80,
                      delete: true,
                    ),
                    const SizedBox(height: 8),
                    const Text("프로필 사진"),
                    const SizedBox(height: 8),
                    Text(
                      "본인 얼굴을 정면으로 가깝게 찍어주세요.",
                      style: Theme.of(context).textTheme.labelSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '이름',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  "본인 인증에 사용됩니다. 반드시 본명을 입력하세요.",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('이름을 입력하세요.'),
                        ),
                      );
                      return;
                    }

                    UserService.instance.user?.update(displayName: nameController.text);
                  },
                  child: const Text(
                    '저장',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
