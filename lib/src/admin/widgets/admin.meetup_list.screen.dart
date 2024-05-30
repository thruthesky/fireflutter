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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetup List'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Expanded(
              child: MeetupListView(
                padding: const EdgeInsets.all(0),
                itemBuilder: (meetup, index) => Card(
                  child: Padding(
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
                            CachedNetworkImage(
                              imageUrl: meetup.photoUrl!,
                              width: 50,
                              height: 50,
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
