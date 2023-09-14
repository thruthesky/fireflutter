import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Admin chat room list
///
/// Note that, it may be an illegal operation to view chat messages of users.
///
class AdminCategoryListScreen extends StatelessWidget with FirebaseHelper {
  const AdminCategoryListScreen({
    super.key,
    this.onTapCategory,
  });

  final Function(Category category)? onTapCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Theme.of(context).colorScheme.onInverseSurface),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        title: Text('Admin Chat List', style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              CategoryService.instance.showCreateDialog(
                context,
                success: (category) {
                  Navigator.pop(context);
                  CategoryService.instance.showUpdateDialog(context, category.id);
                },
              );
            },
          ),
        ],
      ),
      body: FirestoreListView(
          query: chatCol,
          itemBuilder: (context, snapshot) {
            final room = Room.fromDocumentSnapshot(snapshot);
            return ListTile(
              title: Text("TODO - display player and coach name and display chat time, ${room.roomId}${room.name}"),
              onTap: () {},
            );
          }),
    );
  }
}
