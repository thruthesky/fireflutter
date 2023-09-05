import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FavoriteListView extends StatelessWidget {
  const FavoriteListView({super.key});

  @override
  Widget build(BuildContext context) {
    return FirestoreListView(
      query: Favorite.query(),
      itemBuilder: (context, doc) {
        final favorite = Favorite.fromDocumentSnapshot(doc);

        return Card(
          child: Column(
            children: [
              Text('type: ${favorite.type}'),
              ListTile(
                title: Text(favorite.id),
                subtitle: Text(favorite.createdAt.toString()),
              ),
            ],
          ),
        );
      },
    );
  }
}
