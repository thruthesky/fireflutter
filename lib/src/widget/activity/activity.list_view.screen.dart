import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';

class ActivityListViewScreen extends StatefulWidget {
  const ActivityListViewScreen({super.key});

  @override
  State<ActivityListViewScreen> createState() => _ActivityListViewScreenState();
}

class _ActivityListViewScreenState extends State<ActivityListViewScreen> {
  Map<String, bool> filter = {
    ActivityType.user.name: true,
    ActivityType.post.name: true,
    ActivityType.comment.name: true,
    ActivityType.chat.name: true,
    ActivityType.feed.name: true,
  };

  get query {
    Query q;

    if (search.text.isNotEmpty) {
      q = activityUserLogRef(search.text).orderByChild('reverseCreatedAt');
      // q = activityLogRef.orderByChild('reverseCreatedAt').equalTo(search.text, key: 'uid');
    } else {
      q = activityLogRef.orderByChild('reverseCreatedAt');
    }

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
        bottom: PreferredSize(preferredSize: const Size.fromHeight(90), child: userSearch),
      ),
      body: FirebaseDatabaseListView(
        key: const Key('AdminActivityLogListView'),
        query: query,
        itemBuilder: (context, snapshot) {
          final activity = Activity.fromDocumentSnapshot(snapshot);
          if (activity.type == ActivityType.user.name && filter[ActivityType.user.name] == false) {
            return const SizedBox.shrink();
          }
          if (activity.type == ActivityType.post.name && filter[ActivityType.post.name] == false) {
            return const SizedBox.shrink();
          }
          if (activity.type == ActivityType.comment.name && filter[ActivityType.comment.name] == false) {
            return const SizedBox.shrink();
          }
          if (activity.type == ActivityType.chat.name && filter[ActivityType.chat.name] == false) {
            return const SizedBox.shrink();
          }
          if (activity.type == ActivityType.feed.name && filter[ActivityType.feed.name] == false) {
            return const SizedBox.shrink();
          }
          return ListTile(
            key: Key(activity.id),
            title: FutureBuilder(
              future: activity.getMessage,
              builder: (c, s) {
                if (s.hasError) {
                  return const Center(child: Text('Something went wrong.'));
                }
                if (s.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator.adaptive());
                }
                return Text(s.data!);
              },
            ),
            subtitle: Text(dateTimeAgo(activity.createdAt)),
          );
        },
      ),
    );
  }

  Widget get userSearch => Column(
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
                ...ActivityType.values
                    .map(
                      (t) => InkWell(
                        onTap: () => setState(() {
                          filter[t.name] = !filter[t.name]!;
                        }),
                        child: Row(
                          children: [
                            Checkbox(
                              value: filter[t.name],
                              onChanged: (b) => setState(() {
                                filter[t.name] = b!;
                              }),
                            ),
                            Text(t.name),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          )
        ],
      );
}
