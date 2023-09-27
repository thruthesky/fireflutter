import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminFileListScreen extends StatefulWidget {
  const AdminFileListScreen({super.key, this.onTap});

  final Function(Storage)? onTap;

  @override
  State<AdminFileListScreen> createState() => _AdminFileListScreenState();
}

class _AdminFileListScreenState extends State<AdminFileListScreen> {
  final scrollBarControlller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdminFileList'),
      ),
      body: FirestoreQueryBuilder(
        query: storageCol.orderBy('createdAt', descending: true),
        builder: (_, snapshots, __) {
          if (snapshots.isFetching) return const Center(child: CircularProgressIndicator());
          if (snapshots.hasError) return Text('Something went wrong! ${snapshots.error}');

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150,
            ),
            itemCount: snapshots.docs.length,
            itemBuilder: ((context, index) {
              // if we reached the end of the currently obtained items, we try to
              // obtain more items
              if (snapshots.hasMore && index + 1 == snapshots.docs.length) {
                // Tell FirestoreQueryBuilder to try to obtain more items.
                // It is safe to call this function from within the build method.
                snapshots.fetchMore();
              }

              final doc = snapshots.docs[index];
              final file = Storage.fromDocumentSnapshot(doc);
              return InkWell(
                onTap: () {
                  widget.onTap?.call(file);
                },
                child: CachedNetworkImage(
                  imageUrl: file.url,
                  fit: BoxFit.cover,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
