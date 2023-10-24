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
  Map<String, int> cntMap = {};
  int count = 0;
  get query {
    Query q = activityLogCol.orderBy('createdAt', descending: true);

    if (search.text.isNotEmpty) {
      q = q.where('uid', isEqualTo: search.text);
    }

    if (searchType != 'all') {
      q = q.where('type', isEqualTo: searchType);
    }

    q = q.where('type', isEqualTo: 'post');
    // q = q.where('uid', isEqualTo: '6TzeH9PDuJXC29GvBJEwXsv1tV93');
    q = q.where('uid', isEqualTo: 'kxGXsfdW7HhkxwPXqmBl9A0voe22');

    // q = q.where('action', whereIn: ['viewProfile']);
    // q = q.where('id', isEqualTo: 'Dj9ot7LQeanWSwIxJsg0');

    return q;
  }

  TextEditingController search = TextEditingController(text: '');
  String searchType = 'all';

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance.collection('activity_logs').count().get().then((value) => dog('count; ${value.count}'));

    query.count().get().then((value) => dog('count; ${value.count}'));
  }

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
        // bottom: userSearch,
      ),
      body: FirestoreListView(
        pageSize: 20,
        query: query,
        itemBuilder: (context, snapshot) {
          final activity = ActivityLog.fromDocumentSnapshot(snapshot);

          cntMap[activity.id] ??= ++count;
          // count++;

          dog('activity: itemBuilder. ${activity.id}(${cntMap[activity.id]}) ${activity.action} ${activity.uid}}');
          // print('setState(); ${activity.id}(${cntMap[activity.id]})');
          // return Text('activity: itemBuilder. ${activity.id}(${cntMap[activity.id]}) ${activity.action}');
          return ActivityLogTimeLine(
            activity: activity,
          );
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...['all', ...ActivityLogService.instance.adminListViewOptions]
                      .map(
                        (type) => InkWell(
                          onTap: () {
                            setState(() {
                              searchType = type;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio(
                                value: type,
                                groupValue: searchType,
                                onChanged: (String? value) {
                                  dog('value change $value');
                                  if (value != null) {
                                    setState(() {
                                      searchType = value;
                                    });
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: sizeXs),
                                child: Text(
                                  type,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            )
          ],
        ),
      );
}
