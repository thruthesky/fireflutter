import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityLogListViewScreen extends StatefulWidget {
  const ActivityLogListViewScreen({super.key, this.myActivity = false});

  final bool myActivity;

  @override
  State<ActivityLogListViewScreen> createState() => _ActivityLogListViewScreenState();
}

class _ActivityLogListViewScreenState extends State<ActivityLogListViewScreen> {
  Map<String, int> cntMap = {};
  int count = 0;
  get query {
    Query q = activityLogCol.orderBy('createdAt', descending: true);

    if (widget.myActivity == true) {
      q = q.where(
        Filter.or(
          Filter('uid', isEqualTo: myUid),
          Filter('otherUid', isEqualTo: myUid),
        ),
      );
    } else if (search.text.isNotEmpty) {
      q = q.where('uid', isEqualTo: search.text);
    }

    if (searchType != 'all') {
      q = q.where('type', isEqualTo: searchType);
    }

    return q;
  }

  TextEditingController search = TextEditingController(text: '');
  String searchType = 'all';

  @override
  void initState() {
    super.initState();
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
        title: Text(tr.titleActivityLog),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () async {
              setState(() {});
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(widget.myActivity == true ? 32 : 90),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.myActivity == false)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: sizeSm),
                    child: Stack(
                      children: [
                        TextField(
                          controller: search,
                          style: const TextStyle(fontSize: 10),
                          decoration: const InputDecoration(
                            hintText: 'Enter uid',
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
                                visualDensity: const VisualDensity(horizontal: 2, vertical: -2),
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
                      const SizedBox(
                        width: 22,
                      ),
                      ...['all', ...ActivityLogService.instance.activityLogTypes]
                          .map(
                            (type) => GestureDetector(
                              behavior: HitTestBehavior.opaque,
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
                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                    groupValue: searchType,
                                    onChanged: (String? value) {
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
                                      labelText(type),
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
          ),
        ),
      ),
      body: FirestoreListView(
        // itemExtent: 350,
        pageSize: 20,
        query: query,
        itemBuilder: (context, snapshot) {
          final activity = ActivityLog.fromDocumentSnapshot(snapshot);

          cntMap[activity.id] ??= ++count;
          dog('activity: itemBuilder. ${activity.id}(${cntMap[activity.id]}) ${activity.action} ${activity.uid}}');

          return ActivityLogTimeLine(
            activity: activity,
          );
        },
      ),
    );
  }
}

String labelText(String type) {
  if (type == 'user') {
    return toBeginningOfSentenceCase(tr.labelUser)!;
  } else if (type == 'post') {
    return toBeginningOfSentenceCase(tr.labelPost)!;
  } else if (type == 'comment') {
    return toBeginningOfSentenceCase(tr.labelComment)!;
  } else if (type == 'chat') {
    return toBeginningOfSentenceCase(tr.chat)!;
  } else if (type == 'all') {
    return toBeginningOfSentenceCase(tr.labelAll)!;
  }
  return toBeginningOfSentenceCase(type)!;
}
