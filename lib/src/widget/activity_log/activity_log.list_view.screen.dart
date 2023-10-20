import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/activity_log/activity_log.dart';
import 'package:flutter/material.dart';

class ActivityListViewScreen extends StatefulWidget {
  const ActivityListViewScreen({super.key});

  @override
  State<ActivityListViewScreen> createState() => _ActivityListViewScreenState();
}

class _ActivityListViewScreenState extends State<ActivityListViewScreen> {
  // Map<String, bool> filter = {
  //   Log.type.user: true,
  //   Log.type.post: true,
  //   Log.type.comment: true,
  //   Log.type.chat: true,
  //   Log.type.feed: true,
  // };

  get query {
    Query q = activityLogCol.orderBy('createdAt', descending: true);

    if (search.text.isNotEmpty) {
      q = q.where('uid', isEqualTo: search.text);
    }
    // dog('filter: $filter');
    // dog(filter.entries.where((e) => e.value).map((e) => e.key).toList().toString());
    // q.where('type', whereIn: filter.entries.where((e) => e.value).map((e) => e.key).toList());

    return q;
  }

  TextEditingController search = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('AdminActivityLogBackButton'),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Activity logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () async {
              setState(() {});
            },
          )
        ],
        bottom: userSearch,
      ),
      body: FirestoreListView(
        key: const Key('AdminActivityLogListView'),
        query: query,
        itemBuilder: (context, snapshot) {
          final activity = ActivityLog.fromDocumentSnapshot(snapshot);

          return ActivityLogTimeLine(activity: activity);
        },
      ),
    );
  }

  PreferredSize get userSearch => PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: sizeSm),
              child: Stack(
                children: [
                  TextField(
                    controller: search,
                    style: const TextStyle(fontSize: 10),
                    decoration: const InputDecoration(
                      hintText: 'Enter user id',
                      helperMaxLines: 2,
                      helperStyle: TextStyle(fontSize: 10),
                    ),
                    onSubmitted: (v) => setState(() {}),
                  ),
                  Positioned(
                    right: 0,
                    top: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (search.text.isNotEmpty)
                          IconButton(
                            onPressed: () {
                              search.text = '';
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_outlined),
                          ),
                        IconButton(
                          onPressed: () {
                            AdminService.instance.showUserSearchDialog(
                              context,
                              field: 'name',
                              onTap: (user) async {
                                search.text = user.uid;
                                Navigator.of(context).pop();
                                setState(() {});
                              },
                            );
                          },
                          icon: const Icon(Icons.search),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: Row(
            //     children: [
            //       ...Log.type
            //           .map(
            //             (t) => InkWell(
            //               onTap: () => setState(() {
            //                 filter[t.name] = !filter[t.name]!;
            //               }),
            //               child: Row(
            //                 children: [
            //                   Checkbox(
            //                     value: filter[t.name],
            //                     onChanged: (b) => setState(() {
            //                       filter[t.name] = b!;
            //                     }),
            //                   ),
            //                   Text(t.name),
            //                 ],
            //               ),
            //             ),
            //           )
            //           .toList(),
            //     ],
            //   ),
            // )
          ],
        ),
      );
}
