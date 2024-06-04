import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupScreen extends StatefulWidget {
  static const String routeName = '/Meetup';
  const MeetupScreen({super.key});

  @override
  State<MeetupScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MeetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetup'),
        actions: const [
          MeetupCreateButton(),
          SizedBox(width: 24),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'new'),
                Tab(text: 'recommended'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  MeetupListView(
                    padding: const EdgeInsets.all(0),
                    itemBuilder: (meetup, index) => Card(
                      child: InkWell(
                        onTap: () => MeetupService.instance.showViewScreen(
                          context: context,
                          meetup: meetup,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (meetup.photoUrl != null)
                              CachedNetworkImage(
                                imageUrl: meetup.photoUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(meetup.name),
                                Text(
                                  meetup.description,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (meetup.recommendOrder != null)
                                  Text(
                                    '${meetup.recommendOrder}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  MeetupListView(
                    padding: const EdgeInsets.all(0),
                    query: Meetup.col
                        .where('hasPhoto', isEqualTo: true)
                        .orderBy('recommendOrder', descending: true),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
