import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  String filter = 'all';
  String uid = '';

  get query {
    Query q = storageCol.orderBy('createdAt', descending: true);

    if (uid.isNotEmpty) {
      q = q.where('uid', isEqualTo: uid);
    }

    if (filter == 'all') {
    } else if (filter == 'images') {
      q = q.where('isImage', isEqualTo: true);
    } else if (filter == 'videos') {
      q = q.where('isVideo', isEqualTo: true);
    } else if (filter == 'others') {
      q = q.where('isImage', isEqualTo: false).where('isVideo', isEqualTo: false);
    }

    return q;
  }

  get textButtonBackgroudColor => MaterialStateProperty.all<Color>(Theme.of(context).primaryColor.withOpacity(0.2));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr.titleAdminFileList),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 32,
                child: Row(
                  children: [
                    selectionButton('all', tr.labelAll),
                    selectionButton('images', tr.labelImages),
                    selectionButton('videos', tr.labelVideos),
                    selectionButton('others', tr.labelOthers),
                    const Spacer(),
                    TextButton(
                      key: const Key('AdminFileListSearchUserButton'),
                      style: const ButtonStyle(
                        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                      ),
                      onPressed: () {
                        AdminService.instance.showUserSearchDialog(context, field: 'name', onTap: (user) async {
                          uid = user.uid;
                          Navigator.of(context).pop();
                          setState(() {});
                        });
                      },
                      child: Text(tr.labelUserSearch),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 32,
                child: Row(
                  children: [
                    if (uid.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 6, bottom: 6),
                        child: Text("Search by uid: "),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Theme.of(context).primaryColor.withOpacity(0.2)),
                        ),
                        child: Text(uid),
                        onPressed: () {
                          uid = '';
                          setState(() {});
                        },
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: FirestoreQueryBuilder(
        query: query,
        builder: (_, snapshots, __) {
          if (snapshots.isFetching) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshots.hasError) {
            return Center(child: Text('Something went wrong! ${snapshots.error}'));
          }

          if (snapshots.docs.isEmpty) {
            return const Center(child: Text('No files found!'));
          }

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

  selectionButton(String filter, String label) {
    return TextButton(
      style: ButtonStyle(
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        backgroundColor: filter == this.filter ? textButtonBackgroudColor : null,
      ),
      onPressed: () {
        this.filter = filter;
        setState(() {});
      },
      child: Text(label),
    );
  }
}
