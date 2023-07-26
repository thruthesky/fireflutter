import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easychat/easychat.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final displayName = TextEditingController();
  final photoUrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Profile'),
      ),
      body: FutureBuilder(
          future: EasyChat.instance.myDoc.get(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final user = UserModel.fromDocumentSnapshot(snapshot.data as DocumentSnapshot);
            displayName.text = user.displayName;
            photoUrl.text = user.photoUrl;

            return Column(
              children: [
                const SizedBox(height: 24),
                Text('UID: ${user.uid}'),
                const SizedBox(height: 24),
                const Text('Name'),
                TextField(
                  controller: displayName,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),
                const Text('Photo Url'),
                TextField(
                  controller: photoUrl,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                    onPressed: () {
                      EasyChat.instance.myDoc.update({
                        'displayName': displayName.text,
                        'photoUrl': photoUrl.text,
                      });
                    },
                    child: const Text('Update')),
              ],
            );
          }),
    );
  }
}
