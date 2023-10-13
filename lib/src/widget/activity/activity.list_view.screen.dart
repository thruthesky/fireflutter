import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';

class ActivityListViewScreen extends StatefulWidget {
  const ActivityListViewScreen({super.key});

  @override
  State<ActivityListViewScreen> createState() => _ActivityListViewScreenState();
}

class _ActivityListViewScreenState extends State<ActivityListViewScreen> {
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
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              await showModalBottomFilterSheet();
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: userSearch),
        ),
      ),
      body: FirebaseDatabaseListView(
        query: activityLogRef.orderByChild('type').equalTo('user'),
        // reverse: true,
        itemBuilder: (context, snapshot) {
          final activity = Activity.fromDocumentSnapshot(snapshot);
          return ListTile(
            title: Text(
                '${activity.name.isNotEmpty ? activity.name : activity.uid} ${activity.action} ${activity.type} ${activity.otherUid} '),
            subtitle: Text(dateTimeShort(activity.createdAt)),
          );
        },
      ),
    );
  }

  Widget get userSearch => Stack(
        children: [
          TextField(
            controller: search,
            style: const TextStyle(fontSize: 10),
            decoration: const InputDecoration(
              label: Text(
                "Input user id",
              ),
              hintText: 'Input user Id',
              helperMaxLines: 2,
              helperStyle: TextStyle(fontSize: 10),
            ),
          ),
          Positioned(
            right: 0,
            top: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    AdminService.instance.showUserSearchDialog(context,
                        onTap: (user) async {
                      search.text = user.uid;
                      Navigator.of(context).pop();
                    });
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
        ],
      );

  showModalBottomFilterSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints.loose(Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 0.80)),
          child: SafeArea(
            child: StatefulBuilder(
              builder: (context, setFilterModalState) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(sizeSm, sizeSm, sizeSm,
                      MediaQuery.of(context).viewInsets.bottom),
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filter',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(width: 48, height: 48)
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
