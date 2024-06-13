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
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                  ),
                  MeetupListView(
                    query: MeetupService.instance.recommendedQuery,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (meetup, index) => MeetupCard(meetup: meetup),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
