import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminIdCardScreen extends StatelessWidget {
  const AdminIdCardScreen({super.key});

  Query get query {
    Query query = User.col;

    query = query.where('isComplete', isEqualTo: true);

    query = query.where('isVerified', isEqualTo: false);

    return query;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ID Cards')),
      body: FirestoreListView(
        query: query,
        itemBuilder: (context, snapshot) {
          final user = User.fromDocumentSnapshot(snapshot);

          return ListTile(
            title: Text(user.displayName),
            subtitle: Column(
              children: [
                Text(user.createdAt.toString()),
                FutureBuilder<ListResult>(
                    future: FirebaseStorage.instance
                        .ref()
                        .child("ids/${user.uid}")
                        .listAll(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          !snapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      final refs = snapshot.data?.items ?? [];

                      return Wrap(
                        children: refs
                            .map(
                              (e) => FutureBuilder<String>(
                                future: e.getDownloadURL(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.waiting ||
                                      !snapshot.hasData) {
                                    return const SizedBox.shrink();
                                  }
                                  return Image.network(snapshot.data!);
                                },
                              ),
                            )
                            .toList(),
                      );
                    })
              ],
            ),
            leading: UserAvatar(user: user),
            onTap: () async {
              toast(
                  title: 'TODO - verification',
                  message:
                      'See the user photo and ID card. And if they are the same, then set the isVerified to true');
            },
          );
        },
        loadingBuilder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
