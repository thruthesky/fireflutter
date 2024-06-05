import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminMeetupListScreen extends StatefulWidget {
  static const String routeName = '/AdminMeetupList';
  const AdminMeetupListScreen({super.key});

  @override
  State<AdminMeetupListScreen> createState() => _AdminMeetupListScreenState();
}

class _AdminMeetupListScreenState extends State<AdminMeetupListScreen> {
  String selectedItem = 'all';
  Map<String, dynamic> menuItem = {
    'all': T.all.tr,
    'recommend': T.recommend.tr,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetup List'),
        actions: [
          PopupMenuButton(
            initialValue: selectedItem,
            child: const Icon(Icons.menu),
            onSelected: (v) => setState(() => selectedItem = v),
            itemBuilder: (BuildContext context) =>
                menuItem.entries.toList().map<PopupMenuEntry>((v) {
              return PopupMenuItem(
                value: v.key,
                child: Text(menuItem[v.key]),
              );
            }).toList(),
          ),
          const SizedBox(width: 24)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: MeetupListView(
                
                query: (selectedItem == 'recommend')
                    ? MeetupService.instance.recommendedQuery
                    : null,
                padding: const EdgeInsets.all(0),
                itemBuilder: (meetup, index) =>
                    // MeetupListTile(meetup: meetup)

                    Card(
                  child: Stack(children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: InkWell(
                        onTap: () => MeetupService.instance.showViewScreen(
                          context: context,
                          meetup: meetup,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (meetup.photoUrl != null)
                              Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: CachedNetworkImage(
                                  imageUrl: meetup.photoUrl!,
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(meetup.name),
                                  Text(
                                    meetup.description,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (meetup.recommendOrder != null)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                            ),
                            Text(
                              '${meetup.recommendOrder}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
